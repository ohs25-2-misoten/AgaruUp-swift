//
//  AgeView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct AgeView: View {
    @State private var isShowingSearch = false

    // TODO: 実際のユーザーIDとロケーションIDを取得するロジックを実装
    // - userIdはアプリ起動時にUUIDを生成してUserDefaultsに保存
    // - locationIdは位置情報から最寄りのカメラIDを取得
    private let userId = UUID().uuidString
    private let locationId = "c5f806ab-6674-41e0-b869-aaa5f55e36c3"

    var body: some View {
        NavigationStack {
            VStack {
                ProgressIndicator(
                    userId: userId,
                    locationId: locationId
                ) {
                    // 完了時のコールバック（必要に応じて実装）
                    print("アゲ報告完了！")
                }
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
