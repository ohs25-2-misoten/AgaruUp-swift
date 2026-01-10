//
//  SearchResultsView.swift
//  AgaruUp
//
//  Created on 2026/01/11.
//

import SwiftUI

/// 検索結果を表示するビュー
struct SearchResultsView: View {
    /// 検索クエリ（フリーワード）
    let query: String?
    /// タグ検索（タグ名）
    let tag: String?
    
    @State private var videos: [Video] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Bindable var playbackManager: VideoPlaybackManager
    
    private let videoService = VideoService.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    /// 表示用のタイトル
    private var displayTitle: String {
        if let tag {
            return "#\(tag)"
        } else if let query {
            return "「\(query)」の検索結果"
        }
        return "検索結果"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - カスタムヘッダーエリア
            
            HStack {
                Text(displayTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if !videos.isEmpty {
                    Text("\(videos.count)件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color.clear)
            
            // MARK: - メインコンテンツ
            
            ZStack {
                if isLoading, videos.isEmpty {
                    // ローディング表示
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("検索中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage, videos.isEmpty {
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
                                await searchVideos()
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
                } else if videos.isEmpty {
                    // 空状態表示
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("動画が見つかりませんでした")
                            .font(.headline)
                        Text("別のキーワードで検索してみてください")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 動画一覧表示（グリッド形式）
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(videos) { video in
                                NavigationLink {
                                    FeedView(playbackManager: playbackManager, initialVideoId: video.movieId)
                                } label: {
                                    SearchResultGridItem(video: video)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 80)
                    }
                    .refreshable {
                        await searchVideos()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await searchVideos()
        }
    }
    
    // MARK: - Methods
    
    /// 動画を検索
    private func searchVideos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            videos = try await videoService.searchVideos(
                query: query,
                tags: tag,
                limit: 50
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - 検索結果グリッドアイテム

private struct SearchResultGridItem: View {
    let video: Video
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 動画サムネイル
            VideoThumbnailView(videoURL: video.videoUrl)
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
                
                // タグ表示
                if !video.tags.isEmpty {
                    Text(video.tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SearchResultsView(
            query: "テスト",
            tag: nil as String?,
            playbackManager: VideoPlaybackManager()
        )
    }
}
