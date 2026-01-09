//
//  ProgressIndicator.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import CoreBluetooth
import SwiftUI

struct ProgressIndicator: View {
    @State private var progress: Double = 0.0
    @State private var showConfetti: Bool = false
    @State private var isCompleted: Bool = false
    @State private var isReporting: Bool = false

    // アラート用のState
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false

    // BLE有効化確認ダイアログ用のState
    @State private var showEnableBLEAlert: Bool = false

    /// BLEセントラルマネージャー
    @Bindable var bleManager: BLECentralManager

    private let stepAmount: Double = 0.1
    private let backgroundColor = Color.gray.opacity(0.3)
    private let indicatorColor = Color.orange

    /// ユーザーID（API送信用）
    var userId: String = "eb2df825-ece7-4806-a38a-91fd223d1254"
    /// ロケーションID（API送信用）
    var locationId: String = "c5f806ab-6674-41e0-b869-aaa5f55e36c3"
    /// 完了時のコールバック（任意）
    var onComplete: (() -> Void)?

    /// デバッグモード: trueの場合、失敗時にリセットしない
    var isDebugMode: Bool = false

    /// イニシャライザ
    init(
        bleManager: BLECentralManager = .shared,
        userId: String = "eb2df825-ece7-4806-a38a-91fd223d1254",
        locationId: String = "c5f806ab-6674-41e0-b869-aaa5f55e36c3",
        isDebugMode: Bool = false,
        onComplete: (() -> Void)? = nil
    ) {
        self.bleManager = bleManager
        self.userId = userId
        self.locationId = locationId
        self.isDebugMode = isDebugMode
        self.onComplete = onComplete
    }

    /// 進捗に応じた上部のグラデーション色
    private var topGradientColor: Color {
        // 進捗が上がるにつれて透明からオレンジに変化
        Color.orange.opacity(progress * 0.8)
    }

    var body: some View {
        ZStack {
            // 動的グラデーション背景
            LinearGradient(
                colors: [
                    topGradientColor,
                    Color(.systemBackground),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 25) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .frame(height: 30)

                    RoundedRectangle(cornerRadius: 15)
                        .fill(indicatorColor)
                        .frame(width: max(0, min(CGFloat(progress) * 300, 300)), height: 30)
                        .shadow(color: indicatorColor.opacity(0.5), radius: 5, x: 0, y: 3)

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(progress > 0.4 ? .white : .black.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: 300)
                .animation(.easeInOut(duration: 0.5), value: progress)

                // アゲボタン
                Button(action: {
                    if !bleManager.isEnabled {
                        // BLE無効時はダイアログを表示
                        showEnableBLEAlert = true
                    } else {
                        incrementProgress()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(bleManager.isEnabled ? Color.orange : Color.gray)
                            .shadow(
                                color: (bleManager.isEnabled ? Color.orange : Color.gray).opacity(
                                    0.5), radius: 10, x: 0, y: 5)

                        if isReporting {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
                        } else if !bleManager.isEnabled {
                            // BLE無効時は無効表示
                            VStack(spacing: 8) {
                                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("カメラ検出が無効")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else if !bleManager.isDeviceFound {
                            // 検索中はロード表示
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text("対応機器を検索中")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            Text(isCompleted ? "🎉" : "アガる")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 280, height: 280)
                .contentShape(Circle())
                .disabled(
                    isCompleted || isReporting
                        || (bleManager.isEnabled && !bleManager.isDeviceFound))

                // BLEスキャン オン/オフ トグル
                Toggle(isOn: Bindable(bleManager).isEnabled) {
                    HStack {
                        Image(
                            systemName: bleManager.isEnabled
                                ? "antenna.radiowaves.left.and.right"
                                : "antenna.radiowaves.left.and.right.slash"
                        )
                        .foregroundColor(bleManager.isEnabled ? .green : .gray)
                        Text("カメラ検出")
                            .font(.subheadline)
                    }
                }
                .tint(.green)
                .padding(.horizontal, 40)
                .padding(.top, 16)

                // デバイス情報表示（発見時のみ）
                if let device = bleManager.discoveredDevice {
                    VStack(spacing: 4) {
                        Text("UUID: \(device.id.uuidString.prefix(8))...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "距離: %.1f m", device.distance))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                }

                // 検出した未対応デバイスリスト（上がフェードアウト、下からふわっと表示）
                if bleManager.isEnabled && !bleManager.scannedPeripheralList.isEmpty {
                    VStack(alignment: .center, spacing: 4) {
                        Text("検出中のデバイス")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .center, spacing: 4) {
                                    ForEach(bleManager.scannedPeripheralList) { peripheral in
                                        HStack {
                                            Text(peripheral.name ?? "名前なし")
                                                .font(.caption2)
                                                .foregroundColor(.primary)
														 Text(peripheral.id.uuidString.prefix(16) + "...")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .id(peripheral.id)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                    }
                                }
                                .animation(.easeOut(duration: 0.3), value: bleManager.scannedPeripheralList.count)
                            }
                            .frame(height: 60)
                            // 上がグラデーションで透明になるマスク
                            .mask(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .black.opacity(0.3),
                                        .black,
                                        .black,
													 .black.opacity(0.5)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .onChange(of: bleManager.scannedPeripheralList.count) { _, _ in
                                // 新しいアイテムが追加されたら一番下にスクロール
                                if let lastItem = bleManager.scannedPeripheralList.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastItem.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 280)
                    .padding(.top, 8)
                }
            }
            .padding()

            // パーティクルエフェクト
            ConfettiView(isShowing: $showConfetti)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if isSuccess {
                    resetState()
                    onComplete?()
                } else if !isDebugMode {
                    // デバッグモードでない場合は失敗時もリセット
                    resetState()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .alert("カメラ検出を有効にしますか？", isPresented: $showEnableBLEAlert) {
            Button("有効にする") {
                bleManager.isEnabled = true
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("アゲ報告をするには、近くのカメラを検出する必要があります。")
        }
        .onAppear {
            // 画面表示時にBluetooth許可をリクエスト（初期化のみ、自動ONはしない）
            bleManager.initialize()

            // isEnabledがtrueの場合（UserDefaultsから復元された場合）スキャン開始
            if bleManager.isEnabled && bleManager.bluetoothState == .poweredOn {
                bleManager.startScanning()
            }
        }
        .onChange(of: bleManager.bluetoothState) { _, state in
            // Bluetoothが有効になったとき、isEnabledがtrueならスキャン開始
            if state == .poweredOn && bleManager.isEnabled {
                bleManager.startScanning()
            }
        }
    }

    /// プログレスを増加させ、100%になったらAPIを呼び出す
    private func incrementProgress() {
        progress = min(1.0, progress + stepAmount)

        // 100%に達したらアニメーション再生 → API呼び出し
        if progress >= 1.0 && !isCompleted {
            handleCompletion()
        }
    }

    /// 100%達成時の処理
    private func handleCompletion() {
        isCompleted = true

        // パーティクルエフェクトを表示
        showConfetti = true

        // API呼び出し
        Task {
            await sendReport()
        }
    }

    /// 状態を初期状態にリセット
    private func resetState() {
        progress = 0.0
        isCompleted = false
        isReporting = false
        showConfetti = false
        isSuccess = false
    }

    /// 接続デバイスのUUIDを使ってAPIリクエストを送信
    private func sendReport() async {
        isReporting = true

        // 接続デバイスのUUIDを取得
        guard let device = bleManager.discoveredDevice else {
            await MainActor.run {
                isSuccess = false
                alertTitle = "エラー 😢"
                alertMessage = "接続デバイスが見つかりません"
                showAlert = true
                isCompleted = false
            }
            isReporting = false
            return
        }

        // あらかじめ取得済みのデバイスUUIDをlocationIdとして使用
        let deviceLocationId = device.id.uuidString.lowercased()

        do {
            let response = try await ReportService.shared.report(
                userId: userId,
                locationId: deviceLocationId
            )

            print("===== アゲ報告完了 =====")
            print("User ID: \(userId)")
            print("Location ID (Device UUID): \(deviceLocationId)")
            print("Response: \(String(describing: response))")
            print("========================")

            await MainActor.run {
                isSuccess = true
                alertTitle = "成功 🎉"
                alertMessage = "アゲ報告が完了しました！"
                showAlert = true
            }
        } catch {
            print("===== アゲ報告失敗 =====")
            print("Error: \(error)")
            print("LocalizedDescription: \(error.localizedDescription)")
            print("========================")

            await MainActor.run {
                isSuccess = false
                alertTitle = "エラー 😢"
                alertMessage = "報告に失敗しました: \(error.localizedDescription)"
                showAlert = true
                // 失敗時はリトライ可能にする
                isCompleted = false
            }
        }

        isReporting = false
    }
}

#Preview {
    ProgressIndicator(
        userId: "preview-user-id",
        locationId: "preview-location-id",
        isDebugMode: false
    )
}
