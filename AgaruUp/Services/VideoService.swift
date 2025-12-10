//
//  VideoService.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// 動画関連のAPIサービス
final class VideoService: Sendable {
  static let shared = VideoService()

  private let apiClient = APIClient.shared

  private init() {}

  // MARK: - 動画検索

  /// 動画を検索する
  /// - Parameters:
  ///   - query: 検索ワード（任意）
  ///   - tags: タグでフィルタリング（任意）
  ///   - limit: 取得件数の上限（任意）
  /// - Returns: 動画の配列
  nonisolated func searchVideos(query: String? = nil, tags: String? = nil, limit: Int? = nil)
    async throws -> [Video]
  {
    var queryItems: [URLQueryItem] = []

    if let query = query {
      queryItems.append(URLQueryItem(name: "q", value: query))
    }

    if let tags = tags {
      queryItems.append(URLQueryItem(name: "tags", value: tags))
    }

    if let limit = limit {
      queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
    }

    return try await apiClient.get("/videos", queryItems: queryItems)
  }

  // MARK: - 動画UUID指定検索

  /// 複数の動画IDで動画を一括取得する
  /// - Parameter videoIds: 動画のUUID配列
  /// - Returns: 動画の配列
  nonisolated func getBulkVideos(videoIds: [String]) async throws -> [Video] {
    let request = BulkVideosRequest(videos: videoIds)
    return try await apiClient.post("/videos/bulk", body: request)
  }
}
