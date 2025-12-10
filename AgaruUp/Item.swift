//
//  Item.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import Foundation
import SwiftData

@Model
final class Item {
  var timestamp: Date

  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
