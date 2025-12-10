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
  
  @State private var isFavorite = false
  @State private var isAnimating = false
  
  private let favoriteService = FavoriteService.shared

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
              handleFavoriteTap()
            } label: {
              VStack {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                  .resizable()
                  .frame(width: 20, height: 20)
                  .foregroundStyle(isFavorite ? .red : .white)
                  .scaleEffect(isAnimating ? 1.3 : 1.0)
                  .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
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
    .task {
      await loadFavoriteStatus()
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: date)
  }
  
  @MainActor
  private func loadFavoriteStatus() async {
    do {
      isFavorite = try favoriteService.isFavorite(movieId: video.movieId)
    } catch {
      print("お気に入り状態の読み込みエラー: \(error)")
    }
  }
  
  @MainActor
  private func handleFavoriteTap() {
    Task {
      do {
        let newState = try favoriteService.toggleFavorite(movieId: video.movieId)
        isFavorite = newState
        
        // アニメーション
        isAnimating = true
        try? await Task.sleep(nanoseconds: 300_000_000)
        isAnimating = false
      } catch {
        print("お気に入りの切り替えエラー: \(error)")
      }
    }
  }
}
