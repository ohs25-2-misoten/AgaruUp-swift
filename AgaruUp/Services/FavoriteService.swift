//
//  FavoriteService.swift
//  AgaruUp
//
//  Created on 2025/12/10.
//

import Foundation
import SwiftData

/// お気に入り動画を管理するサービス
///
/// **スレッドセーフティに関する注意:**
/// - 全てのメソッドは@MainActorで保護されており、メインスレッドでの実行が保証されています
/// - ModelContextはスレッドセーフではないため、必ずメインスレッドから呼び出してください
/// - 複数のビューから同時にアクセスされる可能性がありますが、@MainActorにより
///   操作は順次実行されるため、競合状態は発生しません
///
/// **使用方法:**
/// ```swift
/// // アプリ起動時に一度だけ設定
/// FavoriteService.shared.configure(with: modelContainer)
///
/// // 各ビューから使用
/// Task { @MainActor in
///   try await FavoriteService.shared.addFavorite(movieId: "movie-id")
/// }
/// ```
@MainActor
final class FavoriteService {
  static let shared = FavoriteService()

  private var modelContainer: ModelContainer?
  private var modelContext: ModelContext?

  private init() {}

  /// ModelContainerを設定する
  /// - Parameter container: SwiftDataのModelContainer
  func configure(with container: ModelContainer) {
    self.modelContainer = container
    self.modelContext = ModelContext(container)
  }

  // MARK: - お気に入り追加

  /// 動画をお気に入りに追加
  /// - Parameter movieId: 動画のUUID
  /// - Throws: SwiftDataのエラー
  func addFavorite(movieId: String) throws {
    guard let context = modelContext else {
      throw FavoriteServiceError.contextNotConfigured
    }

    // 既に存在する場合は何もしない
    if try isFavorite(movieId: movieId) {
      return
    }

    let favorite = FavoriteVideo(movieId: movieId)
    context.insert(favorite)
    try context.save()
  }

  // MARK: - お気に入り削除

  /// 動画をお気に入りから削除
  /// - Parameter movieId: 動画のUUID
  /// - Throws: SwiftDataのエラー
  func removeFavorite(movieId: String) throws {
    guard let context = modelContext else {
      throw FavoriteServiceError.contextNotConfigured
    }

    let descriptor = FetchDescriptor<FavoriteVideo>(
      predicate: #Predicate { $0.movieId == movieId }
    )

    let favorites = try context.fetch(descriptor)

    for favorite in favorites {
      context.delete(favorite)
    }

    try context.save()
  }

  // MARK: - お気に入り判定

  /// 指定した動画がお気に入りかどうかを判定
  /// - Parameter movieId: 動画のUUID
  /// - Returns: お気に入りの場合true
  /// - Throws: SwiftDataのエラー
  func isFavorite(movieId: String) throws -> Bool {
    guard let context = modelContext else {
      throw FavoriteServiceError.contextNotConfigured
    }

    let descriptor = FetchDescriptor<FavoriteVideo>(
      predicate: #Predicate { $0.movieId == movieId }
    )

    let count = try context.fetchCount(descriptor)
    return count > 0
  }

  // MARK: - お気に入り一覧取得

  /// お気に入り動画の一覧を取得
  /// - Returns: お気に入り動画の配列（追加日時降順）
  /// - Throws: SwiftDataのエラー
  func fetchAllFavorites() throws -> [FavoriteVideo] {
    guard let context = modelContext else {
      throw FavoriteServiceError.contextNotConfigured
    }

    let descriptor = FetchDescriptor<FavoriteVideo>(
      sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
    )

    return try context.fetch(descriptor)
  }

  /// お気に入り動画のIDリストを取得
  /// - Returns: 動画IDの配列（追加日時降順）
  /// - Throws: SwiftDataのエラー
  func fetchFavoriteIds() throws -> [String] {
    let favorites = try fetchAllFavorites()
    return favorites.map { $0.movieId }
  }

  // MARK: - お気に入りトグル

  /// お気に入り状態をトグル（追加/削除を切り替え）
  /// - Parameter movieId: 動画のUUID
  /// - Returns: 切り替え後の状態（お気に入りの場合true）
  /// - Throws: SwiftDataのエラー
  @discardableResult
  func toggleFavorite(movieId: String) throws -> Bool {
    if try isFavorite(movieId: movieId) {
      try removeFavorite(movieId: movieId)
      return false
    } else {
      try addFavorite(movieId: movieId)
      return true
    }
  }
}

// MARK: - エラー定義

enum FavoriteServiceError: LocalizedError {
  case contextNotConfigured

  var errorDescription: String? {
    switch self {
    case .contextNotConfigured:
      return "FavoriteServiceが初期化されていません"
    }
  }
}
