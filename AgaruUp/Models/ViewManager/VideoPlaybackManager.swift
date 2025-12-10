//
//  VideoPlaybackManager.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/27.
//

import AVFoundation
import Foundation
import SwiftUI

@Observable
final class VideoPlaybackManager {
  let player = AVPlayer()

  private var savedProgress: [String: Double] = [:]
  private var currentVideoUrl: String?

  var isWarmedUp: Bool = false

  func getLocalVideoURL(fileName: String, fileExtension: String) -> URL? {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
      print("Error: Local video file \(fileName).\(fileExtension) not found in the bundle.")
      return nil
    }
    return url
  }

  func warmupPlayer(with dummyURL: URL) {
    guard !isWarmedUp else { return }

    let dummyItem = AVPlayerItem(url: dummyURL)
    player.replaceCurrentItem(with: dummyItem)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.player.replaceCurrentItem(with: nil)
      self.isWarmedUp = true
    }
  }

  func loadVideo(url: URL) {
    let urlString = url.absoluteString

    if urlString == currentVideoUrl {
      player.play()
      return
    }

    saveCurrentProgress()

    let playerItem = AVPlayerItem(url: url)

    player.replaceCurrentItem(with: playerItem)
    currentVideoUrl = urlString

    if let savedTime = savedProgress[urlString] {
      let time = CMTime(seconds: savedTime, preferredTimescale: 600)

      player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) {
        [weak self] isFinished in
        if isFinished {
          self?.player.play()
        }
      }
    } else {
      player.play()
    }
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
}
