//
//  FeedView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import AVKit
import SwiftUI

struct FeedView: View {
    @Bindable var playbackManager: VideoPlaybackManager
    @State private var videos: [Video] = []
    @State private var scrollPosition: String?
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// 特定の動画IDから開始する場合に指定
    let initialVideoId: String?

    private let videoService = VideoService.shared

    init(playbackManager: VideoPlaybackManager, initialVideoId: String? = nil) {
        self.playbackManager = playbackManager
        self.initialVideoId = initialVideoId
    }

    var body: some View {
        ZStack {
            if isLoading, videos.isEmpty {
                ProgressView("動画を読み込み中...")
            } else if let errorMessage, videos.isEmpty {
                VStack {
                    Text("エラー")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("再試行") {
                        Task {
                            await loadVideos()
                        }
                    }
                    .padding()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(videos) { video in
                            FeedCell(video: video, player: playbackManager.player)
                                .id(video.id)
                                .onAppear { playInitialVideoIfNecessary() }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollPosition)
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea()
                .onChange(of: scrollPosition) { _, newValue in
                    playVideoOnChangeOfScrollPosition(videoId: newValue)
                }
            }
        }
        .task {
            await loadVideos()
            // loadVideos完了後にスクロール位置を設定
            if let initialVideoId {
                scrollPosition = initialVideoId
            }
        }
        .onDisappear {
            playbackManager.pauseAndSave()
        }
    }

    private func loadVideos() async {
        isLoading = true
        errorMessage = nil

        do {
            var loadedVideos = try await videoService.searchVideos(limit: 10)

            // 初期動画IDが指定されている場合
            if let initialVideoId {
                // 指定された動画を取得
                let initialVideos = try await videoService.getBulkVideos(videoIds: [initialVideoId])

                if let initialVideo = initialVideos.first {
                    // おすすめ動画リストから同じIDの動画を削除（重複を防ぐ）
                    loadedVideos.removeAll { $0.movieId == initialVideoId }

                    // 先頭に初期動画を追加
                    videos = [initialVideo] + loadedVideos
                } else {
                    // 初期動画が取得できなかった場合は通常のリストを使用
                    videos = loadedVideos
                }
            } else {
                videos = loadedVideos
            }

            if let firstVideo = videos.first, let url = URL(string: firstVideo.videoUrl) {
                playbackManager.loadVideo(url: url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func playInitialVideoIfNecessary() {
        guard
            scrollPosition == nil,
            let video = videos.first,
            let url = URL(string: video.videoUrl)
        else { return }

        playbackManager.loadVideo(url: url)
    }

    private func playVideoOnChangeOfScrollPosition(videoId: String?) {
        guard let currentVideo = videos.first(where: { $0.id == videoId }),
              let url = URL(string: currentVideo.videoUrl)
        else { return }

        playbackManager.loadVideo(url: url)
    }
}

#Preview {
    FeedView(playbackManager: VideoPlaybackManager())
}
