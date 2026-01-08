//
//  ProgressIndicator.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

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
    
    /// BLEセントラルマネージャー
    private var bleManager = BLECentralManager.shared

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
        userId: String = "eb2df825-ece7-4806-a38a-91fd223d1254",
        locationId: String = "c5f806ab-6674-41e0-b869-aaa5f55e36c3",
        isDebugMode: Bool = false,
        onComplete: (() -> Void)? = nil
    ) {
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
                    Color(.systemBackground)
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

                Button(action: {
                    incrementProgress()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .shadow(color: Color.orange.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        if isReporting {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
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
                .disabled(isCompleted || isReporting)
                
                // BLEデバイス デバッグ情報
                if let device = bleManager.discoveredDevice {
                    VStack(spacing: 8) {
                        Text("🔗 接続デバイス")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("名称:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(device.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("UUID:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(device.id.uuidString.prefix(8) + "...")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("距離:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.2f m", device.distance))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(device.distance <= 5 ? .green : .orange)
                            }
                            
                            HStack {
                                Text("RSSI:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(device.rssi) dBm")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
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
        .onAppear {
            // BLEスキャンを開始
            bleManager.initialize()
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
    
    /// ReportServiceを通じてAPIリクエストを送信
    private func sendReport() async {
		 isReporting = true
        
        do {
            let response = try await ReportService.shared.report(
                userId: userId,
                locationId: locationId
            )
            print("===== アゲ報告成功 =====")
            print("ID: \(response.id ?? "nil")")
            print("Status: \(response.status ?? "nil")")
            print("Message: \(response.message ?? "nil")")
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
