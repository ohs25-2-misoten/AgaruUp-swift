//
//  ContentView.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @State private var isLoggedIn: Bool = false
    var body: some View {
      if isLoggedIn {
        MainTabView()
      } else {
        TopView(isLoggedIn: $isLoggedIn)
      }
    }
}

#Preview {
    ContentView()
}
