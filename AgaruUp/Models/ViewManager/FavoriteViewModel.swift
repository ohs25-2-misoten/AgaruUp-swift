//
//  FavoriteViewModel.swift
//  AgaruUp
//
//  Created on 2025/12/10.
//

import Foundation
import SwiftUI

/// お気に入り画面のViewModel
@MainActor
@Observable
final class FavoriteViewModel {
    /// お気に入り動画の一覧
    private(set) var videos: [Video] = []
    
    /// ローディング状態
    private(set) var isLoading = false
    
    /// エラーメッセージ
    private(set) var errorMessage: String?
    
    private let favoriteService = FavoriteService.shared
    private let videoService = VideoService.shared
    
    // MARK: - お気に入り動画の読み込み
    
    /// お気に入り動画を読み込む
    func loadFavoriteVideos() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // ローカルストレージからお気に入りIDを取得
            let favoriteIds = try favoriteService.fetchFavoriteIds()
            
            // お気に入りが空の場合
            if favoriteIds.isEmpty {
                videos = []
                isLoading = false
                return
            }
            
            // Bulk APIで動画詳細を取得
            let fetchedVideos = try await videoService.getBulkVideos(videoIds: favoriteIds)
            
            // お気に入り追加順（降順）に並べ替え
            videos = sortVideosByFavoriteOrder(videos: fetchedVideos, favoriteIds: favoriteIds)
            
        } catch {
            errorMessage = "お気に入りの読み込みに失敗しました: \(error.localizedDescription)"
            videos = []
        }
        
        isLoading = false
    }
    
    /// 動画をお気に入りの順序でソート
    /// - Parameters:
    ///   - videos: ソート対象の動画配列
    ///   - favoriteIds: お気に入りIDの配列（順序付き）
    /// - Returns: ソート済みの動画配列
    private func sortVideosByFavoriteOrder(videos: [Video], favoriteIds: [String]) -> [Video] {
        var sortedVideos: [Video] = []
        
        for favoriteId in favoriteIds {
            if let video = videos.first(where: { $0.movieId == favoriteId }) {
                sortedVideos.append(video)
            }
        }
        
        return sortedVideos
    }
    
    // MARK: - リフレッシュ
    
    /// お気に入り一覧を更新
    func refresh() async {
        await loadFavoriteVideos()
    }
    
    // MARK: - お気に入り削除
    
    /// 特定の動画をお気に入りから削除
    /// - Parameter movieId: 動画ID
    func removeFavorite(movieId: String) async {
        do {
            try favoriteService.removeFavorite(movieId: movieId)
            // UIから即座に削除
            videos.removeAll { $0.movieId == movieId }
        } catch {
            errorMessage = "お気に入りの削除に失敗しました: \(error.localizedDescription)"
        }
    }
}
