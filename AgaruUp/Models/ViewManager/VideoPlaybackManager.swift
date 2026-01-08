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

        // 前の動画の進捗保存ロジックを削除して、常に最初から再生
        // saveCurrentProgress() 

        let playerItem = AVPlayerItem(url: url)

        player.replaceCurrentItem(with: playerItem)
        currentVideoUrl = urlString

        // 保存された進捗を無視して常に最初から再生
        player.seek(to: .zero)
        player.play()
    }



    func pauseAndSave() {
        player.pause()
    }

    func resume() {
        player.play()
    }
}
