//
//  TopView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/06.
//

import Combine
import SwiftUI

struct TopView: View {
    @Binding var isLoggedIn: Bool
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @State private var currentPage = 0
    @State private var maxSeenPage = 0
    // プログレスバーの進捗 (0.0 ~ 1.0)
    @State private var progress: CGFloat = 0.0

    private let totalPages = 4

    // タイマー設定
    private let pageDuration: TimeInterval = 10.0  // 1ページあたりの表示時間（秒）
    private let timerInterval: TimeInterval = 0.05  // 更新間隔（秒）
    @State private var timerCancellable: AnyCancellable?
    private let timerPublisher = Timer.publish(every: 0.05, on: .main, in: .common)

    // プレースホルダー用の色（後で画像に置き換え）
    private let colors: [Color] = [.brown, .brown, .orange, .orange]
    private let titles = ["Welcome to AgaruUp", "Discover", "Share", "Let's Begin!"]
    private let descriptions = [
        "アゲていくアプリへようこそ！",
        "近くのカメラを見つけてアゲ報告しよう",
        "みんなとアゲを共有しよう",
        "さぁ、はじめよう",
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<totalPages, id: \.self) { index in
                    VStack {
                        Spacer()

                        // 画像プレースホルダー
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors[index])
                            .frame(height: 400)
                            .padding()
                            .overlay(
                                Text("Image \(index + 1)")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            )

                        Spacer()

                        Text(titles[index])
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        Text(descriptions[index])
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()

                        Spacer()

                        // ボタンをカルーセル内に移動
                        Button(action: {
                            if index == totalPages - 1 {
                                completeOnboarding()
                            } else {
                                goToNextPage()
                            }
                        }) {
                            ZStack(alignment: .leading) {
                                // 背景（未完了部分）
                                Color.gray.opacity(0.3)

                                // 完了部分（プログレスバー）の設定
                                if index == totalPages - 1 {
                                    // 最後のページは常に全塗り
                                    Color.orange
                                } else if index == currentPage {
                                    // 現在のページ：progressに従う
                                    GeometryReader { geometry in
                                        Color.orange
                                            .frame(width: geometry.size.width * progress)
                                    }
                                } else if index < maxSeenPage {
                                    // 既読ページ（移動中など）：全塗り
                                    Color.orange
                                }
                                // index > currentPage (未来のページ) は背景グレーのまま

                                // テキスト
                                Text(index == totalPages - 1 ? "はじめる" : "次へ")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 50)
                            .cornerRadius(12)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .onAppear {
            // タイマーを開始
            timerCancellable = timerPublisher.autoconnect().sink { _ in
                // 最後のページ、または既読ページでは自動遷移しない
                guard currentPage < totalPages - 1 else { return }
                guard currentPage == maxSeenPage else { return }

                if progress < 1.0 {
                    withAnimation(.linear(duration: timerInterval)) {
                        progress += CGFloat(timerInterval / pageDuration)
                    }
                } else {
                    goToNextPage()
                }
            }
        }
        .onDisappear {
            // タイマーをキャンセル（メモリリーク防止）
            timerCancellable?.cancel()
            timerCancellable = nil
        }
        .onChange(of: currentPage) { _, newValue in
            // ステート更新がページ遷移アニメーションと干渉しないようにアニメーションを無効化する
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                if newValue > maxSeenPage {
                    maxSeenPage = newValue
                }

                if newValue < maxSeenPage {
                    progress = 1.0
                } else {
                    progress = 0.0
                }
            }
        }
    }

    private func goToNextPage() {
        withAnimation {
            currentPage += 1
        }
    }

    private func completeOnboarding() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
        }
        hasSeenOnboarding = true
        isLoggedIn = true
    }
}

#Preview {
    TopView(isLoggedIn: .constant(false))
}
