//
//  VideoAutoReframeService.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVFoundation
import CoreImage
import Foundation
import Vision

/// 動画の自動リフレームサービス
/// 横長動画から人物を検出し、縦長動画として最適な位置でクロップする
@Observable
final class VideoAutoReframeService {
    static let shared = VideoAutoReframeService()

    /// 処理進捗（0.0〜1.0）
    var progress: Double = 0.0

    /// 処理中かどうか
    var isProcessing: Bool = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 出力アスペクト比（縦長: 9:16）
    private let outputAspectRatio: CGFloat = 9.0 / 16.0

    /// スムージング係数（0.0〜1.0、高いほど滑らか）
    private let smoothingFactor: CGFloat = 0.3

    /// 前回のクロップ中心位置（スムージング用）
    private var lastCropCenterX: CGFloat?

    private init() {}

    // MARK: - Public Methods

    /// 動画を分析してフレームごとのクロップ位置を計算
    /// - Parameter url: 入力動画のURL
    /// - Returns: フレームごとのクロップ領域（正規化座標 0.0〜1.0）
    func analyzeVideo(url: URL) async throws -> [FrameCropInfo] {
        isProcessing = true
        progress = 0.0
        errorMessage = nil
        lastCropCenterX = nil

        defer {
            isProcessing = false
        }

        let asset = AVAsset(url: url)

        // 動画のトラックを取得
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw AutoReframeError.noVideoTrack
        }

        let duration = try await asset.load(.duration)
        let naturalSize = try await videoTrack.load(.naturalSize)
        let transform = try await videoTrack.load(.preferredTransform)

        // 実際のサイズ（回転を考慮）
        let correctedSize = applyCorrectedSize(naturalSize, transform: transform)

        // フレームレートを取得（デフォルト30fps）
        let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
        let fps = nominalFrameRate > 0 ? nominalFrameRate : 30.0

        // 分析間隔（パフォーマンスのため全フレームは分析しない）
        let analysisInterval: Double = 0.1  // 100msごとに分析

        let totalSeconds = CMTimeGetSeconds(duration)
        let totalAnalysisFrames = Int(totalSeconds / analysisInterval) + 1

        var cropInfos: [FrameCropInfo] = []

        // 動画からフレームを抽出して分析
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero

        for i in 0..<totalAnalysisFrames {
            let time = CMTime(seconds: Double(i) * analysisInterval, preferredTimescale: 600)

            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)

                // 人物検出
                let personRects = try await detectPersons(in: cgImage)

                // クロップ位置を計算
                let cropRect = calculateCropRect(
                    personRects: personRects,
                    videoSize: correctedSize
                )

                cropInfos.append(FrameCropInfo(
                    time: time,
                    cropRect: cropRect,
                    detectedPersons: personRects.count
                ))

                // 進捗更新
                await MainActor.run {
                    self.progress = Double(i + 1) / Double(totalAnalysisFrames) * 0.5
                }

            } catch {
                // フレーム取得に失敗した場合はデフォルト位置を使用
                cropInfos.append(FrameCropInfo(
                    time: time,
                    cropRect: CGRect(x: 0.25, y: 0, width: 0.5, height: 1.0),
                    detectedPersons: 0
                ))
            }
        }

        // クロップ位置をスムージング
        let smoothedCropInfos = smoothCropPositions(cropInfos)

        return smoothedCropInfos
    }

    /// 分析結果を使って動画をリフレーム
    /// - Parameters:
    ///   - inputURL: 入力動画のURL
    ///   - outputURL: 出力動画のURL
    ///   - cropInfos: フレームごとのクロップ情報
    func reframeVideo(
        inputURL: URL,
        outputURL: URL,
        cropInfos: [FrameCropInfo]
    ) async throws {
        let asset = AVAsset(url: inputURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw AutoReframeError.noVideoTrack
        }

        let duration = try await asset.load(.duration)
        let naturalSize = try await videoTrack.load(.naturalSize)
        let transform = try await videoTrack.load(.preferredTransform)
        let correctedSize = applyCorrectedSize(naturalSize, transform: transform)

        // 出力サイズを計算（縦長9:16、縮小して処理負荷を下げる）
        let outputHeight: CGFloat = min(correctedSize.height, 1920)
        let outputWidth: CGFloat = outputHeight * outputAspectRatio
        let renderSize = CGSize(width: outputWidth, height: outputHeight)

        // Video Compositionを作成
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw AutoReframeError.compositionFailed
        }

        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: videoTrack,
            at: .zero
        )

        // Audio Track（あれば追加）
        if let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
            if let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) {
                try? compositionAudioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: duration),
                    of: audioTrack,
                    at: .zero
                )
            }
        }

        // Video Compositionの設定
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        // Instructionを作成（時間ベースでクロップ位置を変更）
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(
            assetTrack: compositionVideoTrack
        )

        // クロップ情報を時間順にソート
        let sortedCropInfos = cropInfos.sorted { $0.time < $1.time }

        // 各区間でトランスフォームを設定
        for (index, cropInfo) in sortedCropInfos.enumerated() {
            let cropRect = cropInfo.cropRect

            // 実際のピクセル座標に変換
            let sourceRect = CGRect(
                x: cropRect.origin.x * correctedSize.width,
                y: cropRect.origin.y * correctedSize.height,
                width: cropRect.width * correctedSize.width,
                height: cropRect.height * correctedSize.height
            )

            // スケールと移動を計算
            let scaleX = renderSize.width / sourceRect.width
            let scaleY = renderSize.height / sourceRect.height
            let scale = min(scaleX, scaleY)

            var transformMatrix = CGAffineTransform.identity
            transformMatrix = transformMatrix.translatedBy(
                x: -sourceRect.origin.x * scale,
                y: -sourceRect.origin.y * scale
            )
            transformMatrix = transformMatrix.scaledBy(x: scale, y: scale)

            // 元の動画の回転を適用
            transformMatrix = transform.concatenating(transformMatrix)

            if index < sortedCropInfos.count - 1 {
                let nextTime = sortedCropInfos[index + 1].time
                layerInstruction.setTransformRamp(
                    fromStart: transformMatrix,
                    toEnd: transformMatrix,
                    timeRange: CMTimeRange(start: cropInfo.time, end: nextTime)
                )
            } else {
                layerInstruction.setTransform(transformMatrix, at: cropInfo.time)
            }
        }

        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        // エクスポート
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw AutoReframeError.exportFailed
        }

        // 出力ファイルが既に存在する場合は削除
        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition

        // エクスポート実行
        await exportSession.export()

        // 進捗を監視
        while exportSession.status == .exporting {
            await MainActor.run {
                self.progress = 0.5 + Double(exportSession.progress) * 0.5
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        }

        if exportSession.status == .failed {
            throw exportSession.error ?? AutoReframeError.exportFailed
        }

        await MainActor.run {
            self.progress = 1.0
        }
    }

    /// 分析と変換を一度に実行
    /// - Parameters:
    ///   - inputURL: 入力動画のURL
    ///   - outputURL: 出力動画のURL
    func processVideo(inputURL: URL, outputURL: URL) async throws {
        let cropInfos = try await analyzeVideo(url: inputURL)
        try await reframeVideo(inputURL: inputURL, outputURL: outputURL, cropInfos: cropInfos)
    }

    // MARK: - Private Methods

    /// 人物検出を実行
    private func detectPersons(in image: CGImage) async throws -> [CGRect] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNHumanObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                // 検出された人物の矩形を取得（正規化座標）
                let rects = observations.map { $0.boundingBox }
                continuation.resume(returning: rects)
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// クロップ領域を計算
    private func calculateCropRect(personRects: [CGRect], videoSize: CGSize) -> CGRect {
        // 縦長クロップの幅（元動画の高さを基準に9:16）
        let cropWidth = videoSize.height * outputAspectRatio / videoSize.width

        var centerX: CGFloat

        if personRects.isEmpty {
            // 人物が検出されない場合は中央
            centerX = 0.5
        } else if personRects.count == 1 {
            // 1人の場合はその人物を中心に
            centerX = personRects[0].midX
        } else {
            // 複数人の場合は全員の中心
            let totalMidX = personRects.reduce(0) { $0 + $1.midX }
            centerX = totalMidX / CGFloat(personRects.count)
        }

        // スムージング適用
        if let lastCenter = lastCropCenterX {
            centerX = lastCenter + (centerX - lastCenter) * smoothingFactor
        }
        lastCropCenterX = centerX

        // クロップ領域が画面外に出ないように調整
        let minX = cropWidth / 2
        let maxX = 1.0 - cropWidth / 2
        centerX = max(minX, min(maxX, centerX))

        return CGRect(
            x: centerX - cropWidth / 2,
            y: 0,
            width: cropWidth,
            height: 1.0
        )
    }

    /// クロップ位置をスムージング
    private func smoothCropPositions(_ cropInfos: [FrameCropInfo]) -> [FrameCropInfo] {
        guard cropInfos.count > 1 else { return cropInfos }

        var smoothed = cropInfos
        let windowSize = 5  // 移動平均のウィンドウサイズ

        for i in 0..<cropInfos.count {
            let start = max(0, i - windowSize / 2)
            let end = min(cropInfos.count - 1, i + windowSize / 2)

            var sumX: CGFloat = 0
            var count: CGFloat = 0

            for j in start...end {
                sumX += cropInfos[j].cropRect.origin.x
                count += 1
            }

            let avgX = sumX / count
            smoothed[i] = FrameCropInfo(
                time: cropInfos[i].time,
                cropRect: CGRect(
                    x: avgX,
                    y: 0,
                    width: cropInfos[i].cropRect.width,
                    height: 1.0
                ),
                detectedPersons: cropInfos[i].detectedPersons
            )
        }

        return smoothed
    }

    /// 動画の回転を考慮したサイズを取得
    private func applyCorrectedSize(_ size: CGSize, transform: CGAffineTransform) -> CGSize {
        let isRotated = transform.b != 0 || transform.c != 0
        if isRotated {
            return CGSize(width: size.height, height: size.width)
        }
        return size
    }
}

// MARK: - Supporting Types

/// フレームごとのクロップ情報
struct FrameCropInfo {
    /// フレームの時間
    let time: CMTime
    /// クロップ領域（正規化座標 0.0〜1.0）
    let cropRect: CGRect
    /// 検出された人数
    let detectedPersons: Int
}

/// 自動リフレームエラー
enum AutoReframeError: LocalizedError {
    case noVideoTrack
    case compositionFailed
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "動画トラックが見つかりません"
        case .compositionFailed:
            return "動画の合成に失敗しました"
        case .exportFailed:
            return "動画のエクスポートに失敗しました"
        }
    }
}
