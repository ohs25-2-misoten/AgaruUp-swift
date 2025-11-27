//
//  Post.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import Foundation

struct Post: Codable, Identifiable {
  let id: String
  var videoUrl: String

  init(id: String, videoUrl: String) {
    self.id = id
    self.videoUrl = videoUrl
  }
}
