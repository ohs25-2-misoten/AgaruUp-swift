//
//  VideoPlaybackManager.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/27.
//

import AVKit
import SwiftUI

@Observable
final class VideoPlaybackManager {
  private var savedProgress: [String: Double] = [:]
  private var currentVideoUrl: String?
  let player = AVPlayer()

  func loadVideo(url: URL) {
    let urlString = url.absoluteString

    if urlString == currentVideoUrl {
      return
    }

    saveCurrentProgress()

    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem)
    currentVideoUrl = urlString

    if let savedTime = savedProgress[urlString] {
      let preferredTimescale: CMTimeScale = 600
      let time = CMTime(seconds: savedTime, preferredTimescale: preferredTimescale)
      player.seek(to: time)
    }

    player.play()
  }

  func saveCurrentProgress() {
    guard let url = currentVideoUrl else { return }

    if let currentTime = player.currentItem?.currentTime() {
      let seconds = CMTimeGetSeconds(currentTime)
      if seconds.isFinite && seconds > 0.5 {
        savedProgress[url] = seconds
      }
    }
  }

  func pauseAndSave() {
    player.pause()
    saveCurrentProgress()
  }

  func resume() {
    player.play()
  }

  deinit {
    player.pause()
    player.replaceCurrentItem(with: nil)
  }
}
