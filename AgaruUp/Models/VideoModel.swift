//
//  VideoModel.swift
//  AgaruUp
//
//  Created by GitHub Copilot
//

import Foundation

/// ショート動画を表現するモデル
struct VideoModel: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let title: String
    let description: String
    
    init(url: URL, title: String, description: String = "") {
        self.url = url
        self.title = title
        self.description = description
    }
}

// サンプルデータ
extension VideoModel {
    static let sampleVideos: [VideoModel] = [
        VideoModel(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            title: "Big Buck Bunny",
            description: "サンプル動画1"
        ),
        VideoModel(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
            title: "Elephants Dream",
            description: "サンプル動画2"
        ),
        VideoModel(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
            title: "For Bigger Blazes",
            description: "サンプル動画3"
        ),
        VideoModel(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
            title: "For Bigger Escapes",
            description: "サンプル動画4"
        ),
        VideoModel(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
            title: "For Bigger Fun",
            description: "サンプル動画5"
        )
    ]
}
