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
    private let pageDuration: TimeInterval = 7.0  // 1ページあたりの表示時間（秒）
    private let timerInterval: TimeInterval = 0.05  // 更新間隔（秒）
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

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
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

            VStack {
                Spacer()
                Button(action: {
                    if currentPage == totalPages - 1 {
                        completeOnboarding()
                    } else {
                        goToNextPage()
                    }
                }) {
                    ZStack(alignment: .leading) {
                        if currentPage == totalPages - 1 {
                            // 最後のページは最初から全塗り
                            Color.orange
                        } else {
                            // 背景（未完了部分）
                            Color.gray.opacity(0.3)

                            // 完了部分（プログレスバー）
                            GeometryReader { geometry in
                                Color.orange
                                    .frame(width: geometry.size.width * progress)
                            }
                        }

                        // テキスト
                        Text(currentPage == totalPages - 1 ? "はじめる" : "次へ")
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
            }
        }
        .onReceive(timer) { _ in
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
        .onChange(of: currentPage) { _, newValue in
            if newValue > maxSeenPage {
                maxSeenPage = newValue
            }

            // 既読ページに戻った場合はプログレス満タン、新規ページは0から
            if newValue < maxSeenPage {
                progress = 1.0
            } else {
                progress = 0.0
            }
        }
    }

    private func goToNextPage() {
        withAnimation {
            currentPage += 1
        }
    }

    private func completeOnboarding() {
        hasSeenOnboarding = true
        isLoggedIn = true
    }
}

#Preview {
    TopView(isLoggedIn: .constant(false))
}
