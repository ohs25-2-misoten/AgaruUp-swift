//
//  MainTabView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct MainTabView: View {
    @State private var playbackManager = VideoPlaybackManager()
    @State private var selection: MainTab = .feed
    @SwiftUI.Environment(NotificationManager.self) var notificationManager

    enum MainTab {
        case feed
        case age
        case favorite
        case search
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("アガる動画", systemImage: "video.fill", value: .feed) {
                FeedView(playbackManager: playbackManager)
            }

            Tab("アガる報告", systemImage: "figure.dance", value: .age) {
                AgeView()
            }

            Tab("お気に入り", systemImage: "star", value: .favorite) {
                FavoriteView()
            }

            Tab("検索", systemImage: "magnifyingglass", value: .search, role: .search) {
                SearchView(playbackManager: playbackManager)
            }
        }
        .tint(Color("background"))
        .onChange(of: notificationManager.pendingTabSelection) { newTab in
            print("[MainTabView] pendingTabSelection changed to: \(String(describing: newTab))")
            if let tab = newTab {
                selection = tab
                print("[MainTabView] Switching to tab: \(tab)")
                // 少し遅延させてクリアすることで、連続イベントを防ぐ＆確実に遷移させる
                DispatchQueue.main.async {
                    notificationManager.pendingTabSelection = nil
                }
            }
        }
        .onAppear {
            print("[MainTabView] onAppear. Current pendingTabSelection: \(String(describing: notificationManager.pendingTabSelection))")
            if let tab = notificationManager.pendingTabSelection {
                selection = tab
                print("[MainTabView] Switching to tab (onAppear): \(tab)")
                DispatchQueue.main.async {
                    notificationManager.pendingTabSelection = nil
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
