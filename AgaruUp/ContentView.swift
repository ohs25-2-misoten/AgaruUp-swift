//
//  ContentView.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @State private var isLoggedIn: Bool = false
  @State private var playbackManager = VideoPlaybackManager()
  private let dummyVideoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4")!

    var body: some View {
      if isLoggedIn {
        MainTabView()
          .onAppear {
            playbackManager.warmupPlayer(with: dummyVideoURL)
          }
      } else {
        TopView(isLoggedIn: $isLoggedIn)
      }
    }
}

#Preview {
    ContentView()
}
