//
//  FavoriteVideo.swift
//  AgaruUp
//
//  Created on 2025/12/10.
//

import Foundation
import SwiftData

/// お気に入り動画のローカルストレージモデル
@Model
final class FavoriteVideo {
  /// 動画のUUID
  @Attribute(.unique) var movieId: String

  /// お気に入りに追加した日時
  var addedAt: Date

  init(movieId: String, addedAt: Date = Date()) {
    self.movieId = movieId
    self.addedAt = addedAt
  }
}
