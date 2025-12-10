//
//  FavoriteView.swift
//  AgaruUp
//
//

import AVKit
import SwiftUI

struct FavoriteView: View {
  @State private var isShowingSearch = false
  @State private var viewModel = FavoriteViewModel()
  @State private var playbackManager = VideoPlaybackManager()
  @State private var scrollPosition: String?

  private let columns = [
    GridItem(.flexible(), spacing: 15),
    GridItem(.flexible(), spacing: 15),
  ]

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // MARK: - カスタムヘッダーエリア
        HStack {
          Text("お気に入り")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.primary)

          Spacer()

          Button(action: {
            isShowingSearch = true
          }) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 20, weight: .semibold))
              .foregroundStyle(.black)
              .padding(12)
              .background(Color.white)
              .clipShape(Circle())
              .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.clear)

        // MARK: - メインコンテンツ
        ZStack {
          if viewModel.isLoading && viewModel.videos.isEmpty {
            // ローディング表示
            VStack(spacing: 16) {
              ProgressView()
              Text("お気に入りを読み込み中...")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else if let errorMessage = viewModel.errorMessage, viewModel.videos.isEmpty {
            // エラー表示
            VStack(spacing: 16) {
              Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
              Text("エラー")
                .font(.headline)
              Text(errorMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
              Button {
                Task {
                  await viewModel.loadFavoriteVideos()
                }
              } label: {
                Label("再読み込み", systemImage: "arrow.clockwise")
                  .padding(.horizontal, 24)
                  .padding(.vertical, 12)
                  .background(Color.accentColor)
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else if viewModel.videos.isEmpty {
            // 空状態表示
            VStack(spacing: 16) {
              Image(systemName: "heart.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
              Text("お気に入りがありません")
                .font(.headline)
              Text("動画のハートボタンをタップして\nお気に入りの瞬間を保存してみましょう")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else {
            // 動画一覧表示（グリッド形式）
            ScrollView {
              LazyVGrid(columns: columns, spacing: 24) {
                ForEach(viewModel.videos) { video in
                  NavigationLink {
                    // お気に入りの動画から開始し、その後おすすめ動画が続く
                    FeedView(playbackManager: playbackManager, initialVideoId: video.movieId)
                  } label: {
                    FavoriteVideoGridItem(video: video)
                  }
                  .buttonStyle(.plain)
                  .contextMenu {
                    Button(role: .destructive) {
                      Task {
                        await viewModel.removeFavorite(movieId: video.movieId)
                      }
                    } label: {
                      Label("お気に入りから削除", systemImage: "heart.slash")
                    }
                  }
                }
              }
              .padding(.horizontal, 16)
              .padding(.top, 16)
              .padding(.bottom, 80)
            }
            .refreshable {
              await viewModel.refresh()
            }
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .sheet(isPresented: $isShowingSearch) {
        SearchView()
      }
      .task {
        await viewModel.loadFavoriteVideos()
      }
    }
  }
}

// MARK: - お気に入りグリッドアイテム
private struct FavoriteVideoGridItem: View {
  let video: Video

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // 動画サムネイル
      VideoThumbnailView(videoURL: video.videoUrl)
        .aspectRatio(9 / 16, contentMode: .fit)
        .overlay(
          Image(systemName: "play.circle.fill")
            .font(.system(size: 40))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 2)
        )
        .cornerRadius(12)
        .clipped()

      VStack(alignment: .leading, spacing: 4) {
        Text(video.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .lineLimit(2)
          .foregroundColor(.primary)

        if let date = video.generatedAt {
          Text(formatDate(date))
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: date)
  }
}

#Preview {
  FavoriteView()
}
