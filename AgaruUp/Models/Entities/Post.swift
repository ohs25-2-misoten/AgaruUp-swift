//
//  Post.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import Foundation

struct Post: Codable, Identifiable, Sendable {
    let id: String
    var videoUrl: String
}
