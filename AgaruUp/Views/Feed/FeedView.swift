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
  @State private var posts: [Post] = []
  @State private var scrollPosition: String?

  private let videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
  ]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(posts) { post in
          FeedCell(post: post, player: playbackManager.player)
            .id(post.id)
            .onAppear { playInitialVideoIfNecessary() }
        }
      }
      .scrollTargetLayout()
    }
    .onAppear {
      loadPosts()
      if let firstPost = posts.first, let url = URL(string: firstPost.videoUrl) {
        playbackManager.loadVideo(url: url)
      }
    }
    .onDisappear {
      playbackManager.pauseAndSave()
    }
    .scrollPosition(id: $scrollPosition)
    .scrollTargetBehavior(.paging)
    .ignoresSafeArea()
    .onChange(of: scrollPosition) { _, newValue in
      playVideoOnChangeOfScrollPosition(postId: newValue)
    }
  }

  private func loadPosts() {
    posts = [
      .init(id: UUID().uuidString, videoUrl: videoUrls[0]),
      .init(id: UUID().uuidString, videoUrl: videoUrls[1]),
      .init(id: UUID().uuidString, videoUrl: videoUrls[0]),
    ]
  }

  private func playInitialVideoIfNecessary() {
    guard
      scrollPosition == nil,
      let post = posts.first
    else { return }

    playbackManager.loadVideo(url: URL(string: post.videoUrl)!)
  }

  private func playVideoOnChangeOfScrollPosition(postId: String?) {
    guard let currentPost = posts.first(where: { $0.id == postId }),
          let url = URL(string: currentPost.videoUrl)
    else { return }

    playbackManager.loadVideo(url: url)
  }
}

#Preview {
  FeedView(playbackManager: VideoPlaybackManager())
}
