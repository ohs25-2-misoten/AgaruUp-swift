//
//  RealtimeReframeVideoPlayer.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVFoundation
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

    /// 追跡を有効にするか
    @State private var trackingEnabled: Bool = true

    /// フレーム分析用のタイマー
    @State private var analysisTimer: Timer?

    /// 動画出力
    @State private var videoOutput: AVPlayerItemVideoOutput?

    /// スムージング係数
    private let smoothingFactor: CGFloat = 0.15

    /// 出力アスペクト比（縦長9:16）
    private let outputAspectRatio: CGFloat = 9.0 / 16.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 動画をクロップ表示
                VideoLayerView(player: player)
                    .frame(
                        width: calculateSourceWidth(containerHeight: geometry.size.height),
                        height: geometry.size.height
                    )
                    .offset(x: calculateOffset(containerWidth: geometry.size.width))
                    .clipped()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .onAppear {
            setupVideoOutput()
            startAnalysis()
        }
        .onDisappear {
            stopAnalysis()
        }
    }

    /// 動画出力をセットアップ
    private func setupVideoOutput() {
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        videoOutput = output

        if let currentItem = player.currentItem {
            currentItem.add(output)
        }

        // currentItemの変更を監視
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { _ in
            // ループ時にもビデオ出力を維持
        }
    }

    /// フレーム分析を開始
    private func startAnalysis() {
        // 100msごとに分析（10fps）
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                await analyzeCurrentFrame()
            }
        }
    }

    /// フレーム分析を停止
    private func stopAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
    }

    /// 現在のフレームを分析
    @MainActor
    private func analyzeCurrentFrame() async {
        guard trackingEnabled,
              let output = videoOutput,
              let currentItem = player.currentItem else { return }

        let currentTime = player.currentTime()

        // フレームが利用可能か確認
        guard output.hasNewPixelBuffer(forItemTime: currentTime) else { return }

        // ピクセルバッファを取得
        guard let pixelBuffer = output.copyPixelBuffer(
            forItemTime: currentTime,
            itemTimeForDisplay: nil
        ) else { return }

        // 人物検出を実行
        do {
            let personCenter = try await detectPersonCenter(in: pixelBuffer)

            // スムージング適用
            let smoothedCenter = detectedPersonCenter + (personCenter - detectedPersonCenter) * smoothingFactor
            detectedPersonCenter = smoothedCenter

            // オフセットを計算（0.5が中央、0.0〜1.0の範囲）
            // 検出位置が中央からどれだけずれているかをオフセットに変換
            panOffset = (smoothedCenter - 0.5) * 2.0

        } catch {
            // 検出に失敗した場合は中央を維持
            print("[ReframePlayer] Detection error: \(error)")
        }
    }

    /// 人物検出を実行して中心位置を返す
    private func detectPersonCenter(in pixelBuffer: CVPixelBuffer) async throws -> CGFloat {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNHumanObservation],
                      !observations.isEmpty else {
                    // 人物が検出されない場合は現在位置を維持
                    continuation.resume(returning: self.detectedPersonCenter)
                    return
                }

                // 最も大きい（近い）人物の中心位置を返す
                if let largestPerson = observations.max(by: { $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height }) {
                    continuation.resume(returning: largestPerson.boundingBox.midX)
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

    /// ソース動画の表示幅を計算（縦に合わせて横をはみ出させる）
    private func calculateSourceWidth(containerHeight: CGFloat) -> CGFloat {
        // 縦長表示なので、高さに合わせた横幅を計算
        // 動画のアスペクト比が16:9と仮定
        let videoAspectRatio: CGFloat = 16.0 / 9.0
        return containerHeight * videoAspectRatio
    }

    /// パンオフセットを計算
    private func calculateOffset(containerWidth: CGFloat) -> CGFloat {
        // 動画のはみ出し部分の最大オフセット
        guard let currentItem = player.currentItem else { return 0 }

        let videoSize = currentItem.presentationSize
        guard videoSize.height > 0 else { return 0 }

        let videoAspectRatio = videoSize.width / videoSize.height
        let containerAspectRatio = outputAspectRatio

        // 動画が縦長表示に比べてどれだけ横に広いか
        let excessWidth = (videoAspectRatio / containerAspectRatio - 1.0) * containerWidth / 2

        // panOffset（-1.0〜1.0）をピクセルオフセットに変換
        return -panOffset * excessWidth
    }
}

/// AVPlayerLayerをホストするUIViewRepresentable
struct VideoLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }

    class PlayerUIView: UIView {
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
    }
}

#Preview {
    RealtimeReframeVideoPlayer(
        player: AVPlayer()
    )
    .frame(width: 300, height: 533)
    .background(Color.black)
}
