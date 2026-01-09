//
//  BLECentralManager.swift
//  AgaruUp
//
//  Created on 2026/01/09.
//

import CoreBluetooth
import Foundation

/// 検出されたBLEデバイス情報
struct DiscoveredDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let distance: Double
    var lastSeenAt: Date

    /// RSSIから距離を計算（メートル）
    /// measuredPower: 1メートル地点でのRSSI値（通常-59〜-65dBm）
    /// n: 環境係数（2.0〜4.0、屋内では2.0〜3.0が一般的）
    static func calculateDistance(rssi: Int, measuredPower: Int = -60, n: Double = 3.0) -> Double {
        if rssi == 0 {
            return -1.0
        }
        let ratio = Double(rssi) / Double(measuredPower)
        if ratio < 1.0 {
            return pow(ratio, 10)
        } else {
            return 0.89976 * pow(ratio, 7.7095) + 0.111
        }
    }
}

/// BLEセントラルマネージャー
/// rpi-cameraペリフェラルを探すセントラルとして動作
@Observable
final class BLECentralManager: NSObject {
    static let shared = BLECentralManager()

    /// ターゲットデバイス名
    private let targetDeviceName = "hoso macho"
    /// ターゲットサービスUUID（バックグラウンドスキャンに必要）
    private let targetServiceUUID = CBUUID(string: "CC109F9E-A853-704E-149A-E1DB632AC72F")
    /// 検出距離の閾値（メートル）
    private let distanceThreshold: Double = 10.0

    /// CoreBluetooth Central Manager
    private var centralManager: CBCentralManager!

    /// デバイスが見えなくなったとみなすタイムアウト（秒）
    private let deviceTimeout: TimeInterval = 5.0

    /// 検出された全デバイス
    var discoveredDevices: [UUID: DiscoveredDevice] = [:]

    /// 最も近いデバイス（互換性のために維持）
    var discoveredDevice: DiscoveredDevice? {
        nearestDevice
    }

    /// 最も近いデバイスを取得
    var nearestDevice: DiscoveredDevice? {
        let now = Date()
        // タイムアウトしていないデバイスのみフィルタリング
        let activeDevices = discoveredDevices.values.filter { device in
            now.timeIntervalSince(device.lastSeenAt) < deviceTimeout
        }
        // 距離が最も近いものを返す
        return activeDevices.min { $0.distance < $1.distance }
    }

    /// デバイスが見つかったかどうか
    var isDeviceFound: Bool {
        guard let device = nearestDevice else { return false }
        return device.distance <= distanceThreshold
    }

    /// スキャン中かどうか
    var isScanning: Bool = false

    /// BLEスキャンが有効かどうか（UserDefaultsで永続化）
    private static let isEnabledKey = "bleIsEnabled"
    var isEnabled: Bool = UserDefaults.standard.bool(forKey: isEnabledKey) {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: BLECentralManager.isEnabledKey)
            if isEnabled {
                if centralManager?.state == .poweredOn {
                    startScanning()
                }
            } else {
                stopScanning()
                discoveredDevices.removeAll()
            }
        }
    }

    /// Bluetoothの状態
    var bluetoothState: CBManagerState = .unknown

    private override init() {
        super.init()
    }

    /// BLEスキャンを初期化して開始
    func initialize() {
        guard centralManager == nil else { return }

        // バックグラウンドでのスキャンを有効化
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [CBCentralManagerOptionRestoreIdentifierKey: "com.agaruup.ble.central"]
        )
    }

    /// スキャンを開始
    func startScanning() {
        guard isEnabled else {
            print("[BLE] Scanning is disabled")
            return
        }

        guard centralManager.state == .poweredOn else {
            print("[BLE] Bluetooth is not powered on")
            return
        }

        guard !isScanning else {
            print("[BLE] Already scanning")
            return
        }

        print("[BLE] Starting scan for \(targetDeviceName)")
        isScanning = true

        // サービスUUIDを指定してバックグラウンドスキャンを有効化
        // 距離をリアルタイム更新するため重複検出を有効化
        centralManager.scanForPeripherals(
            withServices: [targetServiceUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
    }

    /// スキャンを停止
    func stopScanning() {
        guard isScanning else { return }

        print("[BLE] Stopping scan")
        centralManager.stopScan()
        isScanning = false
    }
}

// MARK: - CBCentralManagerDelegate

extension BLECentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state

        switch central.state {
        case .poweredOn:
            print("[BLE] Bluetooth is powered on")
            startScanning()
        case .poweredOff:
            print("[BLE] Bluetooth is powered off")
            stopScanning()
        case .resetting:
            print("[BLE] Bluetooth is resetting")
        case .unauthorized:
            print("[BLE] Bluetooth is unauthorized")
        case .unsupported:
            print("[BLE] Bluetooth is unsupported")
        case .unknown:
            print("[BLE] Bluetooth state is unknown")
        @unknown default:
            print("[BLE] Unknown Bluetooth state")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // デバイス名でフィルタリング
        guard let name = peripheral.name, name == targetDeviceName else {
            return
        }

        let rssiValue = RSSI.intValue
        let distance = DiscoveredDevice.calculateDistance(rssi: rssiValue)

        let device = DiscoveredDevice(
            id: peripheral.identifier,
            name: name,
            rssi: rssiValue,
            distance: distance,
            lastSeenAt: Date()
        )

        // バックグラウンド時のみ通知を送信（初回発見またはタイムアウト後の再発見）
        let existingDevice = discoveredDevices[peripheral.identifier]
        let isNewOrRediscovered =
            existingDevice == nil
            || Date().timeIntervalSince(existingDevice!.lastSeenAt) >= deviceTimeout
        if isNewOrRediscovered {
            NotificationManager.shared.sendDeviceFoundNotification(deviceName: name)
        }

        // デバイス情報を更新
        discoveredDevices[peripheral.identifier] = device
    }

    // MARK: - State Restoration

    func centralManager(
        _ central: CBCentralManager,
        willRestoreState dict: [String: Any]
    ) {
        print("[BLE] Restoring state")
        // バックグラウンドから復帰時にスキャンを再開
        if central.state == .poweredOn {
            startScanning()
        }
    }
}
