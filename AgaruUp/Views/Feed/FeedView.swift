//
//  FeedView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import SwiftUI
import AVKit

struct FeedView: View {
  @State private var posts: [Post] = []
  @State private var scrollPosition: String?
  @State private var player = AVPlayer()
  
  private let videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
  ]
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(posts) { post in
          FeedCell(post: post, player: player)
            .id(post.id)
            .onAppear { playInitialVideoIfNecessary() }
        }
      }
      .scrollTargetLayout()
    }
    .onAppear {
      loadPosts()
      player.play()
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
      let post = posts.first,
      player.currentItem == nil else { return }
    let item = AVPlayerItem(url: URL(string: post.videoUrl)!)
    player.replaceCurrentItem(with: item)
  }
  
  private func playVideoOnChangeOfScrollPosition(postId: String?) {
    guard let currentPost = posts.first(where: { $0.id == postId }) else { return }
    
    player.replaceCurrentItem(with: nil)
    let playerItem = AVPlayerItem(url: URL(string: currentPost.videoUrl)!)
    player.replaceCurrentItem(with: playerItem)
  }
}

#Preview {
  FeedView()
}
