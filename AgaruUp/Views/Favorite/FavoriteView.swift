//
//  FavoriteView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct FavoriteView: View {
  @State private var isShowingSearch = false

  var body: some View {
    NavigationStack {
      VStack {
        Text("お気に入り画面")
      }
      .addSearchAppBarButton {
        isShowingSearch = true
      }
      .sheet(isPresented: $isShowingSearch) {
        SearchView()
      }
    }
  }
}

#Preview {
  FavoriteView()
}
