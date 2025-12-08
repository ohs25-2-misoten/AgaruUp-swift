//
//  TagService.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// タグ関連のAPIサービス
final class TagService: Sendable {
    static let shared = TagService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - タグリスト取得
    
    /// 利用可能なタグ一覧を取得する
    /// - Returns: タグ名の配列
    nonisolated func getTags() async throws -> [String] {
        return try await apiClient.get("/tags")
    }
}
