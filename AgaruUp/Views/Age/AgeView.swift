//
//  AgeView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct AgeView: View {
    @State private var isShowingSearch = false
    
    // チュートリアル
    @State private var tutorialManager = AgeTutorialManager.shared
    @State private var spotlightFrames: [AgeTutorialStep: CGRect] = [:]

    // TODO: 実際のユーザーIDとロケーションIDを取得するロジックを実装
    private let userId = UUID().uuidString
    private let locationId = "c5f806ab-6674-41e0-b869-aaa5f55e36c3"
    
    private var currentSpotlightFrame: CGRect {
        spotlightFrames[tutorialManager.currentStep] ?? fallbackFrame(for: tutorialManager.currentStep)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ProgressIndicator(
                        userId: userId,
                        locationId: locationId
                    ) {
                        print("アゲ報告完了！")
                    }
                }
                
                // チュートリアルオーバーレイ
                if tutorialManager.isShowing {
                    AgeTutorialOverlayView(
                        manager: tutorialManager,
                        spotlightFrame: currentSpotlightFrame
                    )
                }
            }
            .onPreferenceChange(AgeSpotlightPreferenceKey.self) { frames in
                spotlightFrames.merge(frames) { _, new in new }
            }
            .onAppear {
                tutorialManager.start()
            }
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
        }
    }
    
    private func fallbackFrame(for step: AgeTutorialStep) -> CGRect {
        let screenSize = UIScreen.main.bounds.size
        
        switch step {
        case .cameraToggle:
            return CGRect(
                x: screenSize.width - 100,
                y: screenSize.height / 2 + 180,
                width: 60,
                height: 35
            )
        case .progressBar:
            return CGRect(
                x: screenSize.width / 2 - 150,
                y: 150,
                width: 300,
                height: 40
            )
        case .button:
            return CGRect(
                x: screenSize.width / 2 - 140,
                y: screenSize.height / 2 - 140,
                width: 280,
                height: 280
            )
        }
    }
}

#Preview {
    AgeView()
}
