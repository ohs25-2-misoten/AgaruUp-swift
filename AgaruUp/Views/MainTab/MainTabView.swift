//
//  MainTabView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      ShortVideoListView()
        .tabItem {
          Image(systemName: "video.fill")
        }

      AgeView()
        .tabItem {
          Image(systemName: "figure.dance")
        }

      FavoriteView()
        .tabItem {
          Image(systemName: "star")
        }
    }
    .tint(Color("background"))
  }
}

#Preview {
  MainTabView()
}
