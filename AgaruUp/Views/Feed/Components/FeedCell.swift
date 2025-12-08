//
//  FeedCell.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import SwiftUI
import AVKit

struct FeedCell: View {
  let video: Video
  var player: AVPlayer

  var body: some View {
    ZStack {
      CustomVideoPlayer(player: player)
        .containerRelativeFrame([.horizontal, .vertical])
      VStack {
        Spacer()
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(video.title)
              .font(.headline)
              .lineLimit(2)
            if let date = video.generatedAt {
              Text(formatDate(date))
                .font(.caption)
            }
          }
          .foregroundStyle(.white)
          
          Spacer()
          
          VStack(spacing: 28) {
            Button {
            } label: {
              VStack {
                Image(systemName: "heart.fill")
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundStyle(.white)
              }
            }
            
            Button {
            } label: {
              VStack {
                Image(systemName: "ellipsis.bubble.fill")
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundStyle(.white)
              }
            }
          }
        }
        .padding(.bottom, 80)
      }
      .padding()
    }
    .onTapGesture {
      switch player.timeControlStatus {
      case .paused:
        player.play()
      case .waitingToPlayAtSpecifiedRate:
        break
      case .playing:
        player.pause()
      @unknown default:
        break
      }
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: date)
  }
}
