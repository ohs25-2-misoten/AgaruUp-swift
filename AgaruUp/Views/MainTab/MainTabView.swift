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
            Tab("アガる動画", systemImage: "video.fill") {
                FeedView(playbackManager: playbackManager)
            }

            Tab("アガる報告", systemImage: "figure.dance") {
                AgeView()
            }

            Tab("お気に入り", systemImage: "star") {
                FavoriteView()
            }

            // iOS 26の検索タブ - role: .searchで切り分けられる
            Tab("検索", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tint(Color("background"))
    }
}

#Preview {
    MainTabView()
}
