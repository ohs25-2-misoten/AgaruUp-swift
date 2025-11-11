//  SplashView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/06.
//

import SwiftUI

struct SplashView: View {
  @State private var move = false

  var body: some View {
    ZStack {
      Color("background")
        .ignoresSafeArea()
      Image("logo")
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
    }
  }
}

#Preview {
  SplashView()
}
