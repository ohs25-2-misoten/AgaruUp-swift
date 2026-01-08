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
            }
            .padding()
            
            // パーティクルエフェクト
            ConfettiView(isShowing: $showConfetti)
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
                resetState()
                onComplete?()
            }
        } catch {
            print("===== アゲ報告失敗（UIは成功扱い） =====")
            print("Error: \(error)")
            print("LocalizedDescription: \(error.localizedDescription)")
            print("========================")
            
            await MainActor.run {
                resetState()
                onComplete?()
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
