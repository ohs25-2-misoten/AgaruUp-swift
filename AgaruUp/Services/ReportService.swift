//
//  ReportService.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// アゲ報告の応答モデル
nonisolated struct ReportResponse: Codable, Sendable {
    /// レポートID
    let id: String?
    /// ステータス
    let status: String?
    /// メッセージ
    let message: String?
}

/// アゲ報告関連のAPIサービス
final class ReportService: Sendable {
    static let shared = ReportService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - アゲ報告
    
    /// アゲ報告を送信する
    /// - Parameters:
    ///   - userId: ユーザーのUUID（モバイルで生成してアプリごとにユニーク）
    ///   - locationId: 最寄りのカメラのUUID
    /// - Returns: レポートの応答
    @discardableResult
    nonisolated func report(userId: String, locationId: String) async throws -> ReportResponse {
        let request = ReportRequest(user: userId, location: locationId)
        return try await apiClient.post("/report", body: request)
    }
}
