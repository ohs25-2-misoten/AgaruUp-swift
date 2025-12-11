//
//  BulkVideosRequest.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// 動画UUID指定検索リクエスト
struct BulkVideosRequest: Codable, Sendable {
  /// 動画のUUIDリスト
  let videos: [String]
}
