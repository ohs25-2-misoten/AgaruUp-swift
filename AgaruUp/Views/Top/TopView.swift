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
    private let totalPages = 4
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

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
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }) {
                    Text(currentPage == totalPages - 1 ? "はじめる" : "スキップ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentPage = (currentPage + 1) % totalPages
            }
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
