//
//  RealtimeReframeVideoPlayer.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVFoundation
import Combine
import SwiftUI
import Vision

/// リアルタイムで人物を追跡し、縦長表示にリフレームする動画プレイヤー
struct RealtimeReframeVideoPlayer: View {
    let player: AVPlayer

    /// 追跡結果に基づくオフセット（-1.0〜1.0、0が中央）
    @State private var panOffset: CGFloat = 0.0

    /// 検出された人物の位置（正規化座標）
    @State private var detectedPersonCenter: CGFloat = 0.5

    /// 動画出力
    @State private var videoOutput: AVPlayerItemVideoOutput?

    /// 分析タスクのキャンセル用
    @State private var analysisTask: Task<Void, Never>?

    /// デバッグ用：検出状態
    @State private var debugInfo: String = "初期化中..."

    /// スムージング係数
    private let smoothingFactor: CGFloat = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TrackingVideoLayerView(
                    player: player,
                    panOffset: panOffset,
                    containerSize: geometry.size
                )

                // デバッグ表示
                VStack {
                    Text(debugInfo)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    Spacer()
                }
                .padding(4)
            }
        }
        .task {
            // Viewが表示されたら分析を開始
            debugInfo = "分析開始"
            print("[ReframePlayer] task started")

            await setupAndStartAnalysis()
        }
        .onDisappear {
            analysisTask?.cancel()
            print("[ReframePlayer] disappeared")
        }
    }

    /// セットアップと分析開始
    @MainActor
    private func setupAndStartAnalysis() async {
        // PlayerItemの準備を待つ
        while player.currentItem == nil {
            debugInfo = "動画待機中..."
            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        // VideoOutputをアタッチ
        guard let item = player.currentItem else {
            debugInfo = "動画なし"
            return
        }

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        item.add(output)
        videoOutput = output

        debugInfo = "分析中"
        print("[ReframePlayer] Video output attached, starting analysis loop")

        // 分析ループ
        while !Task.isCancelled {
            await analyzeCurrentFrame()
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms = 10fps
        }
    }

    /// 現在のフレームを分析
    @MainActor
    private func analyzeCurrentFrame() async {
        guard let output = videoOutput else {
            debugInfo = "出力なし"
            return
        }

        let currentTime = player.currentTime()

        guard let pixelBuffer = output.copyPixelBuffer(
            forItemTime: currentTime,
            itemTimeForDisplay: nil
        ) else {
            debugInfo = "フレーム取得失敗"
            return
        }

        do {
            let personCenter = try await detectPersonCenter(in: pixelBuffer)
            let smoothedCenter = detectedPersonCenter + (personCenter - detectedPersonCenter) * smoothingFactor
            detectedPersonCenter = smoothedCenter

            withAnimation(.easeOut(duration: 0.1)) {
                panOffset = (smoothedCenter - 0.5) * 2.0
            }

            debugInfo = String(format: "検出中 x:%.2f", personCenter)
            print("[ReframePlayer] Person: \(personCenter), Offset: \(panOffset)")
        } catch {
            debugInfo = "検出エラー"
            print("[ReframePlayer] Error: \(error)")
        }
    }

    /// 人物検出
    private func detectPersonCenter(in pixelBuffer: CVPixelBuffer) async throws -> CGFloat {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNHumanObservation],
                      !observations.isEmpty else {
                    // 人物なし -> 中央
                    continuation.resume(returning: 0.5)
                    return
                }

                if let largest = observations.max(by: {
                    $0.boundingBox.area < $1.boundingBox.area
                }) {
                    continuation.resume(returning: largest.boundingBox.midX)
                } else {
                    continuation.resume(returning: 0.5)
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - CGRect Extension

private extension CGRect {
    var area: CGFloat { width * height }
}

// MARK: - Tracking Video Layer

struct TrackingVideoLayerView: UIViewRepresentable {
    let player: AVPlayer
    let panOffset: CGFloat
    let containerSize: CGSize

    func makeUIView(context: Context) -> TrackingPlayerUIView {
        let view = TrackingPlayerUIView()
        view.player = player
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: TrackingPlayerUIView, context: Context) {
        uiView.player = player
        uiView.updatePanOffset(panOffset, containerSize: containerSize)
    }

    class TrackingPlayerUIView: UIView {
        var player: AVPlayer? {
            get { playerLayer.player }
            set { playerLayer.player = newValue }
        }

        var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }

        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            playerLayer.videoGravity = .resizeAspectFill
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func updatePanOffset(_ offset: CGFloat, containerSize: CGSize) {
            guard let videoSize = player?.currentItem?.presentationSize,
                  videoSize.width > 0, videoSize.height > 0 else { return }

            let videoAspectRatio = videoSize.width / videoSize.height
            let containerAspectRatio = containerSize.width / containerSize.height

            guard videoAspectRatio > containerAspectRatio else { return }

            let scaledVideoWidth = containerSize.height * videoAspectRatio
            let maxPanX = (scaledVideoWidth - containerSize.width) / 2
            let translateX = -offset * maxPanX

            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            playerLayer.setAffineTransform(CGAffineTransform(translationX: translateX, y: 0))
            CATransaction.commit()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
    }
}

#Preview {
    RealtimeReframeVideoPlayer(player: AVPlayer())
        .frame(width: 300, height: 533)
        .background(Color.black)
}
