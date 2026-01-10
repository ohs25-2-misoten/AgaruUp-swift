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
    
    // チュートリアル
    @State private var tutorialManager = FeedTutorialManager.shared
    @State private var spotlightFrames: [FeedTutorialStep: CGRect] = [:]

    /// 特定の動画IDから開始する場合に指定
    let initialVideoId: String?

    private let videoService = VideoService.shared

    init(playbackManager: VideoPlaybackManager, initialVideoId: String? = nil) {
        self.playbackManager = playbackManager
        self.initialVideoId = initialVideoId
    }
    
    private var currentSpotlightFrame: CGRect {
        spotlightFrames[tutorialManager.currentStep] ?? fallbackFrame(for: tutorialManager.currentStep)
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
            
            // チュートリアルオーバーレイ
            if tutorialManager.isShowing {
                FeedTutorialOverlayView(
                    manager: tutorialManager,
                    spotlightFrame: currentSpotlightFrame
                )
            }
        }
        .onPreferenceChange(FeedSpotlightPreferenceKey.self) { frames in
            spotlightFrames.merge(frames) { _, new in new }
        }
        .task {
            await loadVideos()
            if let initialVideoId {
                scrollPosition = initialVideoId
            }
        }
        .onAppear {
            // 初回表示時にチュートリアル開始
            tutorialManager.start()
        }
        .onDisappear {
            playbackManager.pause()
        }
    }

    private func loadVideos() async {
        isLoading = true
        errorMessage = nil

        do {
            var loadedVideos = try await videoService.searchVideos(limit: 10)

            if let initialVideoId {
                let initialVideos = try await videoService.getBulkVideos(videoIds: [initialVideoId])

                if let initialVideo = initialVideos.first {
                    loadedVideos.removeAll { $0.movieId == initialVideoId }
                    videos = [initialVideo] + loadedVideos
                } else {
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
    
    private func fallbackFrame(for step: FeedTutorialStep) -> CGRect {
        let screenSize = UIScreen.main.bounds.size
        
        switch step {
        case .swipe:
            return CGRect(
                x: screenSize.width / 2 - 60,
                y: screenSize.height / 2 - 150,
                width: 120,
                height: 300
            )
        case .tap:
            return CGRect(
                x: screenSize.width / 2 - 75,
                y: screenSize.height / 2 - 75,
                width: 150,
                height: 150
            )
        case .download:
            return CGRect(
                x: screenSize.width - 60,
                y: screenSize.height - 215,
                width: 50,
                height: 50
            )
        }
    }
}

#Preview {
    FeedView(playbackManager: VideoPlaybackManager())
}
