//
//  CameraService.swift
//  AgaruUp
//
//  Created on 2025/12/08.
//

import Foundation

/// カメラ関連のAPIサービス
final class CameraService: Sendable {
    static let shared = CameraService()

    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - カメラ情報取得

    /// 指定したIDのカメラ情報を取得する
    /// - Parameter cameraId: カメラのUUID
    /// - Returns: カメラ情報
    nonisolated func getCamera(cameraId: String) async throws -> Camera {
        try await apiClient.get("/cameras/\(cameraId)")
    }
}
