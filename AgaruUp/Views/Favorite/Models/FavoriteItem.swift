//
//  FavoriteItem.swift
//  AgaruUp
//
//  Created by Models on 2025/12/04.
//

import Foundation

/// お気に入りアイテムのデータモデル
struct FavoriteItem: Identifiable {
  // FeedViewのID(String)に合わせてString型
  let id: String
  let imageName: String
  let title: String
  let location: String
  let createdDate: String
}

// MARK: - Mock Data

extension FavoriteItem {
  static let mocks: [FavoriteItem] = [
    FavoriteItem(
      id: "video_1",
      imageName: "photo01",
      title: "過去一アガった瞬間！！",
      location: "大阪府大阪市北区梅田hoge",
      createdDate: "2025/11/19 生成"
    ),
    FavoriteItem(
      id: "video_2",
      imageName: "photo02",
      title: "過去一アガった瞬間！！",
      location: "大阪府大阪市北区梅田hoge",
      createdDate: "2025/11/19 生成"
    ),
    FavoriteItem(
      id: "video_3",
      imageName: "photo03",
      title: "最高のデザート",
      location: "東京都渋谷区",
      createdDate: "2025/11/20 生成"
    ),
  ]
}
