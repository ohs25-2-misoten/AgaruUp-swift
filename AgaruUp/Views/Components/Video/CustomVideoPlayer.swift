//
//  CustomVideoPlayer.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import AVKit
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context _: Context) -> UIViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.exitsFullScreenWhenPlaybackEnds = true
        controller.allowsPictureInPicturePlayback = true
        controller.videoGravity = .resizeAspectFill

        return controller
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}
