//
//  FeedView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import SwiftUI
import AVKit

struct FeedView: View {
  @Bindable var playbackManager: VideoPlaybackManager
  @State private var videos: [Video] = []
  @State private var scrollPosition: String?
  @State private var isLoading = false
  @State private var errorMessage: String?

  private let videoService = VideoService.shared

  var body: some View {
    ZStack {
      if isLoading && videos.isEmpty {
        ProgressView("動画を読み込み中...")
      } else if let errorMessage = errorMessage, videos.isEmpty {
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
    }
    .onDisappear {
      playbackManager.pauseAndSave()
    }
  }

  private func loadVideos() async {
    isLoading = true
    errorMessage = nil
    
    do {
      videos = try await videoService.searchVideos(limit: 10)
      
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
