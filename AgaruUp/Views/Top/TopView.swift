//
//  TopView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/06.
//

import SwiftUI

struct TopView: View {
  @Binding var isLoggedIn: Bool
  var body: some View {
    VStack {
      Button("Sign In with Apple") {
        self.isLoggedIn = true
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
  TopView(isLoggedIn: .constant(false))
}
