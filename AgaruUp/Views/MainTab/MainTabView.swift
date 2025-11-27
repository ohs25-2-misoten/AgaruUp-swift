//
//  MainTabView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct MainTabView: View {
  @State private var playbackManager = VideoPlaybackManager()

  var body: some View {
    TabView {
      FeedView(playbackManager: playbackManager)
        .tabItem {
          Label("アガる動画", systemImage: "video.fill")
        }

      AgeView()
        .tabItem {
          Label("アガる報告", systemImage: "figure.dance")
        }

      FavoriteView()
        .tabItem {
          Label("お気に入り", systemImage: "star")
        }
    }
    .tint(Color("background"))
  }
}

#Preview {
  MainTabView()
}
