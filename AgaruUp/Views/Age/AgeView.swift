//
//  AgeView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct AgeView: View {
  var body: some View {
    NavigationStack {
      VStack {
        ProgressIndicator()
      }
      .addSearchAppBarButton {}
    }
  }
}

#Preview {
  AgeView()
}
