//
//  ShortVideoScrollView.swift
//  AgaruUp
//
//  Created by GitHub Copilot
//

import SwiftUI

/// ショート動画をスナップスクロールで表示するビュー
struct ShortVideoScrollView: View {
    let videos: [VideoModel]
    @State private var currentIndex = 0
    
    init(videos: [VideoModel] = VideoModel.sampleVideos) {
        self.videos = videos
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex) {
                ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                    VideoPlayerView(video: video)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                // 動画インデックス表示
                Text("\(currentIndex + 1) / \(videos.count)")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }
}

#Preview {
    ShortVideoScrollView()
}
