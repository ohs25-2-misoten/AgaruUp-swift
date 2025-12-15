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
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                VideoThumbnailView(videoURL: video.videoUrl)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .aspectRatio(9 / 16, contentMode: .fit)

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                if let date = video.generatedAt {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

// プレビュー用の設定
#Preview {
    // プレビュー用にダミーデータを作成して表示
    let mockVideo = Video(
        title: "プレビュー用のタイトル",
        tags: ["Sample"],
        location: "LocationID",
        generateDate: "2025-12-04T12:00:00Z",
        baseUrl: "https://example.com",
        movieId: "preview_id"
    )

    FavoriteGridItemView(video: mockVideo)
        .frame(width: 180) // グリッドの幅を想定してサイズ制限
        .padding()
}
