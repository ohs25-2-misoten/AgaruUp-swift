//
//  MainTabView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct MainTabView: View {
    @State private var playbackManager = VideoPlaybackManager()
    @State private var searchText: String = ""

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

            // iOS 26で追加されたTabBar統合検索機能
            // Tab(role: .search)はTabBarに虫眼鏡アイコンとして表示され、
            // タップするとSearchView内で.searchable()修飾子で定義された検索バーが有効になる
            Tab(role: .search) {
                NavigationStack {
                    SearchView()
                        .navigationTitle("検索")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .searchable(text: $searchText, prompt: "動画を検索")
            }
        }
        .tint(Color("background"))
    }
}

#Preview {
    MainTabView()
}
