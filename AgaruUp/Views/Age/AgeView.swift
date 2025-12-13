//
//  AgeView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct AgeView: View {
    @State private var isShowingSearch = false

    var body: some View {
        NavigationStack {
            VStack {
                ProgressIndicator()
            }
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
        }
    }
}

#Preview {
    AgeView()
}
