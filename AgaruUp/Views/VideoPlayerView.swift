//
//  VideoPlayerView.swift
//  AgaruUp
//
//  Created by GitHub Copilot
//

import SwiftUI
import AVKit

/// 個別の動画を再生するビュー
struct VideoPlayerView: View {
    let video: VideoModel
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var observer: NSObjectProtocol?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                } else {
                    Color.black
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .tint(.white)
                }
                
                // 動画情報オーバーレイ
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if !video.description.isEmpty {
                            Text(video.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: video.url)
        player?.play()
        isPlaying = true
        
        // ループ再生の設定
        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        
        // オブザーバーを削除
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}

#Preview {
    VideoPlayerView(video: VideoModel.sampleVideos[0])
}
