//
//  FeedCell.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import SwiftUI
import AVKit

struct FeedCell: View {
  let post: Post
  var player: AVPlayer

  var body: some View {
    ZStack {
      CustomVideoPlayer(player: player)
        .containerRelativeFrame([.horizontal, .vertical])
      VStack {
        Spacer()
        HStack {
          VStack(alignment: .leading) {
            Text("") // Title
            Text("") // 生成日
          }
          .foregroundStyle(.white)
          .font(.subheadline)
          
          Spacer()
          
          VStack(spacing: 28) {
            Button {
            } label: {
              VStack {
                Image(systemName: "heart.fill")
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundStyle(.white)
                Text("1.2K") // WebAPIから取得した値にリプレース予定
                  .font(.caption)
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
                Text("345") // WebAPIから取得した値にリプレース予定
                  .font(.caption)
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
}
