//
//  ReportRequest.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// アゲ報告リクエスト
struct ReportRequest: Codable, Sendable {
    /// ユーザーのUUID（モバイルで生成してアプリごとにユニーク）
    let user: String
    /// 最寄りのカメラから取得されたUUID（カメラごとにユニーク）
    let location: String
}
