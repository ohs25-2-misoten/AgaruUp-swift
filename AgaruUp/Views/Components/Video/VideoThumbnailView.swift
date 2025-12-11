//
//  VideoThumbnailView.swift
//  AgaruUp
//
//  Created on 2025/12/10.
//

import AVFoundation
import SwiftUI

/// 動画URLからサムネイル画像を生成して表示するビュー
struct VideoThumbnailView: View {
  let videoURL: String
  @State private var thumbnail: UIImage?
  @State private var isLoading = true

  var body: some View {
    ZStack {
      if let thumbnail = thumbnail {
        Image(uiImage: thumbnail)
          .resizable()
          .scaledToFill()
      } else if isLoading {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
        ProgressView()
          .tint(.white)
      } else {
        // 読み込み失敗時
        Rectangle()
          .fill(Color.gray.opacity(0.3))
        Image(systemName: "video.slash")
          .foregroundColor(.white.opacity(0.6))
          .font(.title)
      }
    }
    .task {
      await loadThumbnail()
    }
  }

  private func loadThumbnail() async {
    guard let url = URL(string: videoURL) else {
      isLoading = false
      return
    }

    let asset = AVURLAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.maximumSize = CGSize(width: 400, height: 600)  // サムネイルサイズを制限

    do {
      let time = CMTime(seconds: 0.5, preferredTimescale: 600)  // 0.5秒の位置から取得
      let cgImage = try await imageGenerator.image(at: time).image
      await MainActor.run {
        self.thumbnail = UIImage(cgImage: cgImage)
        self.isLoading = false
      }
    } catch {
      print("サムネイル生成エラー: \(error)")
      await MainActor.run {
        self.isLoading = false
      }
    }
  }
}

#Preview {
  VideoThumbnailView(
    videoURL:
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
  )
  .frame(width: 200, height: 300)
  .cornerRadius(12)
}
