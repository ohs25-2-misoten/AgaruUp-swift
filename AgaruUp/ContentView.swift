//
//  ContentView.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @State private var playbackManager = VideoPlaybackManager()
    private let dummyVideoURL = URL(
        string:
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    )!

    var body: some View {
        if isLoggedIn {
            MainTabView()
                .onAppear {
                    if let dummyURL = playbackManager.getLocalVideoURL(
                        fileName: "sample", fileExtension: "mp4"
                    ) {
                        playbackManager.warmupPlayer(with: dummyURL)
                    } else {
                        playbackManager.warmupPlayer(with: dummyVideoURL)
                    }
                }
        } else {
            TopView(isLoggedIn: $isLoggedIn)
                .task {
                    // オンボーディング完了済みなら自動的にログイン状態にする
                    if hasSeenOnboarding {
                        isLoggedIn = true
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
