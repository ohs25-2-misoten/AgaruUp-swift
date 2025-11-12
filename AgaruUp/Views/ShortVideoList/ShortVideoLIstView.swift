//
//  ShortVideoLIstView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/06.
//

import SwiftUI

struct ShortVideoListView: View {
  var body: some View {
    NavigationStack {
      VStack {
        Text("ショート動画一覧画面")
      }
      .addSearchAppBarButton {}
    }
  }
}

#Preview {
  ShortVideoListView()
}
