//
//  TutorialOverlayView.swift
//  AgaruUp
//
//  Created by AI Assistant on 2026/01/11.
//

import SwiftUI

// MARK: - フィード画面チュートリアルオーバーレイ

struct FeedTutorialOverlayView: View {
    @Bindable var manager: FeedTutorialManager
    var spotlightFrame: CGRect = .zero
    
    var body: some View {
        ZStack {
            SpotlightMask(
                spotlightFrame: spotlightFrame,
                spotlightShape: manager.currentStep.spotlightShape
            )
            .fill(Color.black.opacity(0.7))
            .ignoresSafeArea()
            
            TooltipView(
                message: manager.currentStep.message,
                position: manager.currentStep.tooltipPosition,
                spotlightFrame: spotlightFrame,
                canGoBack: manager.currentStep.previous != nil,
                isLastStep: manager.currentStep.next == nil,
                onBack: { manager.previousStep() },
                onNext: { manager.nextStep() },
                onSkip: { manager.skip() }
            )
        }
        .animation(.easeInOut(duration: 0.3), value: manager.currentStep)
    }
}

// MARK: - アガる報告画面チュートリアルオーバーレイ

struct AgeTutorialOverlayView: View {
    @Bindable var manager: AgeTutorialManager
    var spotlightFrame: CGRect = .zero
    
    var body: some View {
        ZStack {
            SpotlightMask(
                spotlightFrame: spotlightFrame,
                spotlightShape: manager.currentStep.spotlightShape
            )
            .fill(Color.black.opacity(0.7))
            .ignoresSafeArea()
            
            TooltipView(
                message: manager.currentStep.message,
                position: manager.currentStep.tooltipPosition,
                spotlightFrame: spotlightFrame,
                canGoBack: manager.currentStep.previous != nil,
                isLastStep: manager.currentStep.next == nil,
                onBack: { manager.previousStep() },
                onNext: { manager.nextStep() },
                onSkip: { manager.skip() }
            )
        }
        .animation(.easeInOut(duration: 0.3), value: manager.currentStep)
    }
}

// MARK: - 共通コンポーネント

struct SpotlightMask: Shape {
    var spotlightFrame: CGRect
    var spotlightShape: SpotlightShape
    
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        
        if spotlightFrame != .zero {
            let expandedFrame = spotlightFrame.insetBy(dx: -10, dy: -10)
            
            let spotlightPath: Path
            switch spotlightShape {
            case .ellipse:
                spotlightPath = Path(ellipseIn: expandedFrame)
            case .roundedRectangle:
                spotlightPath = Path(roundedRect: expandedFrame, cornerRadius: 20)
            }
            
            path = path.subtracting(spotlightPath)
        }
        
        return path
    }
}

struct TooltipView: View {
    let message: String
    let position: TooltipPosition
    let spotlightFrame: CGRect
    let canGoBack: Bool
    let isLastStep: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            HStack(spacing: 12) {
                if canGoBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                
                if !isLastStep {
                    Button(action: onSkip) {
                        Text("スキップ")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                
                Button(action: onNext) {
                    Text(isLastStep ? "完了" : "次へ")
                        .font(.headline)
                        .foregroundColor(isLastStep ? .white : .orange)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(isLastStep ? Color.orange : Color.white)
                        )
                }
            }
        }
        .padding()
        .position(tooltipPosition)
    }
    
    private var tooltipPosition: CGPoint {
        let screenSize = UIScreen.main.bounds.size
        let tabBarHeight: CGFloat = 100 // タブバーの高さを考慮
        let tooltipHeight: CGFloat = 150 // 吹き出し+ボタンの高さを考慮
        
        switch position {
        case .center:
            // 画面中央より上（タブバー+ボタンを考慮）
            return CGPoint(x: screenSize.width / 2, y: (screenSize.height - tabBarHeight - tooltipHeight) / 2)
        case .top:
            let y = max(spotlightFrame.minY - 140, 150)
            return CGPoint(x: screenSize.width / 2, y: y)
        case .bottom:
            // タブバー+ボタンの上に表示
            let y = min(spotlightFrame.maxY + 100, screenSize.height - tabBarHeight - tooltipHeight - 50)
            return CGPoint(x: screenSize.width / 2, y: y)
        case .left:
            // タブバーを考慮した位置（ダウンロードボタン説明用）
            let y = min(spotlightFrame.midY, screenSize.height - tabBarHeight - tooltipHeight - 50)
            return CGPoint(x: screenSize.width / 2 - 50, y: y)
        case .right:
            let y = min(spotlightFrame.midY, screenSize.height - tabBarHeight - tooltipHeight - 50)
            return CGPoint(x: screenSize.width / 2 + 50, y: y)
        }
    }
}
