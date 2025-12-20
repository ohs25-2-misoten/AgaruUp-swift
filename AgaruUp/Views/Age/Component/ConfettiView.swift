//
//  ConfettiView.swift
//  AgaruUp
//
//  Created on 2025/12/18.
//

import SwiftUI

/// 紙吹雪（コンフェッティ）のパーティクルエフェクト
struct ConfettiView: View {
    @Binding var isShowing: Bool
    
    /// パーティクルの数
    private let particleCount = 50
    /// アニメーション時間
    private let animationDuration: Double = 2.0
    
    /// パーティクルの色
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isShowing {
                    ForEach(0..<particleCount, id: \.self) { index in
                        ConfettiParticle(
                            color: colors[index % colors.count],
                            delay: Double.random(in: 0...0.3),
                            screenHeight: geometry.size.height,
                            screenWidth: geometry.size.width
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                // アニメーション完了後に非表示にする
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    isShowing = false
                }
            }
        }
    }
}

/// 個別のパーティクル
private struct ConfettiParticle: View {
    let color: Color
    let delay: Double
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    
    @State private var isAnimating = false
    
    /// ランダムな開始位置（横方向）- 画面幅全体に分散
    private var startX: CGFloat {
        CGFloat.random(in: 0...screenWidth)
    }
    /// ランダムな終了位置（横方向のブレ）
    private let endXOffset: CGFloat = CGFloat.random(in: -100...100)
    /// ランダムな回転角度
    private let rotation: Double = Double.random(in: 0...360)
    /// ランダムなサイズ
    private let size: CGFloat = CGFloat.random(in: 8...15)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(isAnimating ? rotation + 360 : rotation))
            .position(
                x: startX + (isAnimating ? endXOffset : 0),
                y: isAnimating ? screenHeight + 50 : -20
            )
            .opacity(isAnimating ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.0)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    @Previewable @State var isShowing = true
    
    VStack {
        ConfettiView(isShowing: $isShowing)
        
        Button("Show Confetti") {
            isShowing = true
        }
        .padding()
    }
}
