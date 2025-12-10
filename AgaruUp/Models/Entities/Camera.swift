//
//  Camera.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// カメラの座標情報
struct Coordinate: Codable, Sendable {
  /// 緯度
  let lat: Double
  /// 経度
  let lng: Double
}

/// カメラ情報を表すモデル
struct Camera: Codable, Identifiable, Sendable {
  /// カメラ名
  let name: String
  /// カメラID（UUID）
  let id: String
  /// 座標情報
  let coordinate: Coordinate
  /// カメラのURL
  let url: String
}
