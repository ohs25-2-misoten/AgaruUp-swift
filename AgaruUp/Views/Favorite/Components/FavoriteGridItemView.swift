//
//  FavoriteGridItemView.swift
//  AgaruUp
//
//  Created by ゆっち on 2025/12/04.
//

import SwiftUI

/// グリッド内の個別のアイテムビュー
/// コンポーネントとして切り出し
struct FavoriteGridItemView: View {
    let item: FavoriteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                // Assetsにある画像名と一致させてください
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .aspectRatio(3 / 4, contentMode: .fit)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Text(item.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(item.createdDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// プレビュー用の設定
#Preview {
    // プレビュー用にダミーデータを作成して表示
    let mockItem = FavoriteItem(
        id: "preview_id",
        imageName: "photo01", // Assetsに画像がない場合はグレーになります
        title: "プレビュー用のタイトル",
        location: "東京都渋谷区",
        createdDate: "2025/12/04 生成"
    )

    FavoriteGridItemView(item: mockItem)
        .frame(width: 180) // グリッドの幅を想定してサイズ制限
        .padding()
}
