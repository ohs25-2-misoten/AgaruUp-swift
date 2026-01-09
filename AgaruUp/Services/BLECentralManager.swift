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
    var peripheral: CBPeripheral?

    /// RSSIから距離を計算（メートル）
    /// measuredPower: 1メートル地点でのRSSI値（通常-59〜-65dBm）
    /// n: 環境係数（2.0〜4.0、屋内では2.0〜3.0が一般的）
    ///
    /// 標準的なBLE距離計算公式: d = 10^((measuredPower - rssi) / (10 * n))
    static func calculateDistance(rssi: Int, measuredPower: Int = -70, n: Double = 3.0) -> Double {
        if rssi == 0 {
            return -1.0
        }
        // 標準的なBLE距離計算公式を使用
        // d = 10^((measuredPower - rssi) / (10 * n))
        let exponent = Double(measuredPower - rssi) / (10.0 * n)
        return pow(10.0, exponent)
    }
}

/// BLEセントラルマネージャー
/// rpi-cameraペリフェラルを探すセントラルとして動作
@Observable
final class BLECentralManager: NSObject {
    static let shared = BLECentralManager()

    /// ターゲットデバイス名
    private let targetDeviceName = "agaru-up-camera"
    /// ターゲットサービスUUID（バックグラウンドスキャンに必要）
    private let targetServiceUUID = CBUUID(string: "5c339364-c7be-4f23-b666-a8ff73a6a86a")
    /// デバイスUUID読み取り用のCharacteristic UUID
    private let deviceUUIDCharacteristicUUID = CBUUID(
        string: "ecf6c084-a579-42da-a7ff-f400fa4f4ae3")
    /// 検出距離の閾値（メートル）
    private let distanceThreshold: Double = 5.0

    /// CoreBluetooth Central Manager
    private var centralManager: CBCentralManager!

    /// デバイスが見えなくなったとみなすタイムアウト（秒）
    private let deviceTimeout: TimeInterval = 60.0

    /// 検出された全デバイス（キー：Characteristicから取得したデバイスUUID）
    var discoveredDevices: [UUID: DiscoveredDevice] = [:]

    /// 発見したペリフェラルの参照を保持（接続用）
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]

    /// ペリフェラルIDとデバイスUUIDのマッピング
    private var peripheralToDeviceUUID: [UUID: UUID] = [:]

    /// 接続待ちのペリフェラル情報（ペリフェラルID → 検出情報）
    private struct PendingPeripheralInfo {
        let name: String
        let rssi: Int
        let distance: Double
        let peripheral: CBPeripheral
    }
    private var pendingPeripherals: [UUID: PendingPeripheralInfo] = [:]

    /// 検出した未対応デバイス情報（デバッグ表示用、UUIDで重複排除）
    struct ScannedPeripheralInfo: Identifiable {
        let id: UUID
        let name: String?
        let discoveredAt: Date
    }
    var scannedPeripherals: [UUID: ScannedPeripheralInfo] = [:]

    /// スキャンされたペリフェラルのリスト（古い順＝下に新しいものが追加されていく）
    var scannedPeripheralList: [ScannedPeripheralInfo] {
        scannedPeripherals.values.sorted { $0.discoveredAt < $1.discoveredAt }
    }

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

    /// 接続中かどうか
    var isConnecting: Bool = false

    /// 接続済みペリフェラル
    private var connectedPeripheral: CBPeripheral?

    /// UUID読み取り完了ハンドラ
    private var readDeviceUUIDCompletion: ((Result<String, Error>) -> Void)?

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
                discoveredPeripherals.removeAll()
                peripheralToDeviceUUID.removeAll()
                pendingPeripherals.removeAll()
                scannedPeripherals.removeAll()
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

        // フォアグラウンドでのみスキャン
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil
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

        // フォアグラウンドでのみスキャン（サービスUUID指定なしで全件検索）
        // 機器名でフィルタリングするため、全てのペリフェラルをスキャン
        // 距離をリアルタイム更新するため重複検出を有効化
        centralManager.scanForPeripherals(
            withServices: nil,
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

    // MARK: - デバイス接続とUUID読み取り

    /// デバイスに接続してUUIDを読み取る
    func connectAndReadDeviceUUID(deviceId: UUID) async throws -> String {
        guard let peripheral = discoveredPeripherals[deviceId] else {
            throw BLEError.deviceNotFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.readDeviceUUIDCompletion = { result in
                continuation.resume(with: result)
            }

            isConnecting = true
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)

            // タイムアウト処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                guard let self = self, self.isConnecting else { return }
                self.isConnecting = false
                self.readDeviceUUIDCompletion?(.failure(BLEError.connectionTimeout))
                self.readDeviceUUIDCompletion = nil
                if let peripheral = self.connectedPeripheral {
                    self.centralManager.cancelPeripheralConnection(peripheral)
                }
            }
        }
    }

    /// 接続を解除
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
        isConnecting = false
    }
}

/// BLEエラー
enum BLEError: LocalizedError {
    case deviceNotFound
    case connectionTimeout
    case serviceNotFound
    case characteristicNotFound
    case readFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .deviceNotFound: return "デバイスが見つかりません"
        case .connectionTimeout: return "接続がタイムアウトしました"
        case .serviceNotFound: return "サービスが見つかりません"
        case .characteristicNotFound: return "Characteristicが見つかりません"
        case .readFailed: return "データの読み取りに失敗しました"
        case .invalidData: return "無効なデータです"
        }
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
            // ターゲット以外のデバイスを検出した場合はリストに追加（デバッグ表示用、UUID重複排除）
            // 既に登録済みの場合は追加順を維持するため更新しない
            if scannedPeripherals[peripheral.identifier] == nil {
                scannedPeripherals[peripheral.identifier] = ScannedPeripheralInfo(
                    id: peripheral.identifier,
                    name: peripheral.name,
                    discoveredAt: Date()
                )
            }
            return
        }

        let rssiValue = RSSI.intValue
        let distance = DiscoveredDevice.calculateDistance(rssi: rssiValue)

        // 既にこのペリフェラルのデバイスUUIDを取得済みの場合は更新のみ
        if let deviceUUID = peripheralToDeviceUUID[peripheral.identifier] {
            // 既存デバイスの情報を更新
            if var existingDevice = discoveredDevices[deviceUUID] {
                existingDevice.lastSeenAt = Date()
                discoveredDevices[deviceUUID] = DiscoveredDevice(
                    id: deviceUUID,
                    name: name,
                    rssi: rssiValue,
                    distance: distance,
                    lastSeenAt: Date(),
                    peripheral: peripheral
                )
            }
            return
        }

        // 既に接続待ちまたは接続中の場合はスキップ
        if pendingPeripherals[peripheral.identifier] != nil || isConnecting {
            return
        }

        // デバッグ用：ターゲットデバイス発見時のみログ出力
        print("[BLE] ✅ ターゲットデバイス発見: \(name) (ペリフェラルID: \(peripheral.identifier), RSSI: \(RSSI.intValue)dBm)")
        print("[BLE] 🔗 Characteristicから機器UUIDを取得するため接続開始...")

        // ペリフェラル参照を保持
        discoveredPeripherals[peripheral.identifier] = peripheral

        // 接続待ち情報を保存
        pendingPeripherals[peripheral.identifier] = PendingPeripheralInfo(
            name: name,
            rssi: rssiValue,
            distance: distance,
            peripheral: peripheral
        )

        // 自動接続してCharacteristicの値を読み取る
        isConnecting = true
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[BLE] Connected to \(peripheral.name ?? "unknown")")
        connectedPeripheral = peripheral
        // サービス発見を開始
        peripheral.discoverServices([targetServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        print("[BLE] Failed to connect: \(error?.localizedDescription ?? "unknown error")")
        pendingPeripherals.removeValue(forKey: peripheral.identifier)
        isConnecting = false
        readDeviceUUIDCompletion?(.failure(error ?? BLEError.connectionTimeout))
        readDeviceUUIDCompletion = nil
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        print("[BLE] Disconnected from \(peripheral.name ?? "unknown")")
        pendingPeripherals.removeValue(forKey: peripheral.identifier)
        connectedPeripheral = nil
        isConnecting = false
    }
}

// MARK: - CBPeripheralDelegate

extension BLECentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("[BLE] Service discovery error: \(error)")
            readDeviceUUIDCompletion?(.failure(error))
            readDeviceUUIDCompletion = nil
            disconnect()
            return
        }

        guard let services = peripheral.services,
            let targetService = services.first(where: { $0.uuid == targetServiceUUID })
        else {
            print("[BLE] Target service not found")
            readDeviceUUIDCompletion?(.failure(BLEError.serviceNotFound))
            readDeviceUUIDCompletion = nil
            disconnect()
            return
        }

        print("[BLE] Found service: \(targetService.uuid)")
        peripheral.discoverCharacteristics([deviceUUIDCharacteristicUUID], for: targetService)
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let error = error {
            print("[BLE] Characteristic discovery error: \(error)")
            readDeviceUUIDCompletion?(.failure(error))
            readDeviceUUIDCompletion = nil
            disconnect()
            return
        }

        guard let characteristics = service.characteristics,
            let targetCharacteristic = characteristics.first(where: {
                $0.uuid == deviceUUIDCharacteristicUUID
            })
        else {
            print("[BLE] Target characteristic not found")
            readDeviceUUIDCompletion?(.failure(BLEError.characteristicNotFound))
            readDeviceUUIDCompletion = nil
            disconnect()
            return
        }

        print("[BLE] Found characteristic: \(targetCharacteristic.uuid)")
        peripheral.readValue(for: targetCharacteristic)
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        defer {
            disconnect()
            // pendingPeripheralsから削除
            pendingPeripherals.removeValue(forKey: peripheral.identifier)
        }

        if let error = error {
            print("[BLE] Read value error: \(error)")
            readDeviceUUIDCompletion?(.failure(error))
            readDeviceUUIDCompletion = nil
            return
        }

        guard let data = characteristic.value,
            let rawUuidString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
            let deviceUUID = UUID(uuidString: rawUuidString.lowercased())
        else {
            print("[BLE] Invalid data or UUID format")
            readDeviceUUIDCompletion?(.failure(BLEError.invalidData))
            readDeviceUUIDCompletion = nil
            return
        }

        print("[BLE] ✅ 機器UUID取得成功: \(deviceUUID)")

        // ペリフェラルIDとデバイスUUIDのマッピングを保存
        peripheralToDeviceUUID[peripheral.identifier] = deviceUUID

        // pendingPeripheralsから情報を取得してDiscoveredDeviceを作成
        if let pendingInfo = pendingPeripherals[peripheral.identifier] {
            let device = DiscoveredDevice(
                id: deviceUUID,
                name: pendingInfo.name,
                rssi: pendingInfo.rssi,
                distance: pendingInfo.distance,
                lastSeenAt: Date(),
                peripheral: pendingInfo.peripheral
            )

            // デバイス情報を更新
            discoveredDevices[deviceUUID] = device

            // 通知を送信
            NotificationManager.shared.sendDeviceFoundNotification(deviceName: pendingInfo.name)

            print("[BLE] 📱 デバイス登録完了: \(pendingInfo.name) (UUID: \(deviceUUID))")
        }

        isConnecting = false
        readDeviceUUIDCompletion?(.success(rawUuidString))
        readDeviceUUIDCompletion = nil
    }
}
