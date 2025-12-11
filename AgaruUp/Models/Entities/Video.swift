//
//  Video.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// 動画情報を表すモデル
struct Video: Codable, Identifiable, Sendable {
  /// タイトル
  let title: String
  /// タグ一覧
  let tags: [String]
  /// ロケーションID（カメラのUUID）
  let location: String
  /// 生成日時
  let generateDate: String
  /// ベースURL
  let baseUrl: String
  /// 動画ID（UUID）
  let movieId: String

  /// Identifiableプロトコル用
  var id: String { movieId }

  /// 完全な動画URLを生成
  var videoUrl: String {
    "\(baseUrl)/\(movieId).mp4"
  }

  /// 生成日時をDate型で取得
  var generatedAt: Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: generateDate) ?? ISO8601DateFormatter().date(from: generateDate)
  }
}
