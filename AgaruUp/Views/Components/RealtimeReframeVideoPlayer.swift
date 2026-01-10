//
//  RealtimeReframeVideoPlayer.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVFoundation
import Combine
import CoreImage
import SwiftUI
import Vision

/// リアルタイムで人物を追跡し、縦長表示にリフレームする動画プレイヤー
struct RealtimeReframeVideoPlayer: View {
    let player: AVPlayer

    /// 追跡結果に基づくオフセット（-1.0〜1.0、0が中央）
    @State private var panOffset: CGFloat = 0.0

    /// 検出された人物の位置（正規化座標）
    @State private var detectedPersonCenter: CGFloat = 0.5

    /// フレーム分析用のタイマー
    @State private var analysisTimer: Timer?

    /// 動画出力
    @State private var videoOutput: AVPlayerItemVideoOutput?

    /// currentItem監視用
    @State private var currentItemObserver: AnyCancellable?

    /// スムージング係数（大きいほど速く追従）
    private let smoothingFactor: CGFloat = 0.25

    var body: some View {
        GeometryReader { geometry in
            TrackingVideoLayerView(
                player: player,
                panOffset: panOffset,
                containerSize: geometry.size
            )
        }
        .onAppear {
            setupPlayerObserver()
            startAnalysis()
        }
        .onDisappear {
            stopAnalysis()
            currentItemObserver?.cancel()
        }
    }

    /// プレイヤーのcurrentItem変更を監視
    private func setupPlayerObserver() {
        if let currentItem = player.currentItem {
            attachVideoOutput(to: currentItem)
        }

        currentItemObserver = player.publisher(for: \.currentItem)
            .sink { newItem in
                if let item = newItem {
                    attachVideoOutput(to: item)
                }
            }
    }

    /// 動画出力をPlayerItemにアタッチ
    private func attachVideoOutput(to item: AVPlayerItem) {
        if let existingOutput = videoOutput {
            item.remove(existingOutput)
        }

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        item.add(output)
        videoOutput = output

        print("[ReframePlayer] Video output attached")
    }

    /// フレーム分析を開始
    private func startAnalysis() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                await analyzeCurrentFrame()
            }
        }
        RunLoop.current.add(analysisTimer!, forMode: .common)
        print("[ReframePlayer] Analysis started")
    }

    /// フレーム分析を停止
    private func stopAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
    }

    /// 現在のフレームを分析
    @MainActor
    private func analyzeCurrentFrame() async {
        guard let output = videoOutput else { return }

        let currentTime = player.currentTime()

        guard let pixelBuffer = output.copyPixelBuffer(
            forItemTime: currentTime,
            itemTimeForDisplay: nil
        ) else { return }

        do {
            let personCenter = try await detectPersonCenter(in: pixelBuffer)
            let smoothedCenter = detectedPersonCenter + (personCenter - detectedPersonCenter) * smoothingFactor
            detectedPersonCenter = smoothedCenter

            withAnimation(.easeOut(duration: 0.15)) {
                panOffset = (smoothedCenter - 0.5) * 2.0
            }

            print("[ReframePlayer] Offset: \(panOffset)")
        } catch {
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
                    continuation.resume(returning: 0.5)
                    return
                }

                if let largest = observations.max(by: {
                    $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
                }) {
                    print("[ReframePlayer] Person at: \(largest.boundingBox.midX)")
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

/// トラッキング対応のビデオレイヤービュー
/// CALayerのtransformを直接操作してパンする
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

            // 動画のアスペクト比
            let videoAspectRatio = videoSize.width / videoSize.height
            // コンテナのアスペクト比
            let containerAspectRatio = containerSize.width / containerSize.height

            // 動画がコンテナより横長の場合のみパンが有効
            guard videoAspectRatio > containerAspectRatio else { return }

            // 動画を高さに合わせたときの実際の表示幅
            let scaledVideoWidth = containerSize.height * videoAspectRatio
            // はみ出す幅の半分（最大パン量）
            let maxPanX = (scaledVideoWidth - containerSize.width) / 2

            // オフセットをピクセルに変換
            let translateX = -offset * maxPanX

            // CALayerにtransformを適用（アニメーション付き）
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.15)
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
