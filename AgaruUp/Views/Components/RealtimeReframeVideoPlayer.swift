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

    /// 追跡を有効にするか
    @State private var trackingEnabled: Bool = true

    /// フレーム分析用のタイマー
    @State private var analysisTimer: Timer?

    /// 動画出力
    @State private var videoOutput: AVPlayerItemVideoOutput?

    /// currentItem監視用
    @State private var currentItemObserver: AnyCancellable?

    /// スムージング係数（大きいほど速く追従）
    private let smoothingFactor: CGFloat = 0.25

    /// 出力アスペクト比（縦長9:16）
    private let outputAspectRatio: CGFloat = 9.0 / 16.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 動画をクロップ表示
                VideoLayerView(player: player)
                    .frame(
                        width: calculateSourceWidth(containerSize: geometry.size),
                        height: geometry.size.height
                    )
                    .offset(x: calculateOffset(containerSize: geometry.size))
                    .animation(.easeOut(duration: 0.15), value: panOffset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
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
        // 初期設定
        if let currentItem = player.currentItem {
            attachVideoOutput(to: currentItem)
        }

        // currentItemの変更を監視
        currentItemObserver = player.publisher(for: \.currentItem)
            .sink { [self] newItem in
                if let item = newItem {
                    attachVideoOutput(to: item)
                }
            }
    }

    /// 動画出力をPlayerItemにアタッチ
    private func attachVideoOutput(to item: AVPlayerItem) {
        // 既存の出力を削除
        if let existingOutput = videoOutput {
            item.remove(existingOutput)
        }

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        item.add(output)
        videoOutput = output

        print("[ReframePlayer] Video output attached to item")
    }

    /// フレーム分析を開始
    private func startAnalysis() {
        // 100msごとに分析（10fps）
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                await analyzeCurrentFrame()
            }
        }
        print("[ReframePlayer] Analysis started")
    }

    /// フレーム分析を停止
    private func stopAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        print("[ReframePlayer] Analysis stopped")
    }

    /// 現在のフレームを分析
    @MainActor
    private func analyzeCurrentFrame() async {
        guard trackingEnabled,
              let output = videoOutput else {
            return
        }

        let currentTime = player.currentTime()

        // ピクセルバッファを取得（hasNewPixelBufferをスキップして強制取得）
        guard let pixelBuffer = output.copyPixelBuffer(
            forItemTime: currentTime,
            itemTimeForDisplay: nil
        ) else {
            return
        }

        // 人物検出を実行
        do {
            let personCenter = try await detectPersonCenter(in: pixelBuffer)

            // スムージング適用
            let smoothedCenter = detectedPersonCenter + (personCenter - detectedPersonCenter) * smoothingFactor
            detectedPersonCenter = smoothedCenter

            // オフセットを計算（0.5が中央、0.0〜1.0の範囲）
            let newOffset = (smoothedCenter - 0.5) * 2.0
            panOffset = newOffset

            print("[ReframePlayer] Person at: \(personCenter), offset: \(newOffset)")

        } catch {
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
                    // 人物が検出されない場合は中央に戻る
                    continuation.resume(returning: 0.5)
                    return
                }

                // 最も大きい（近い）人物の中心位置を返す
                if let largestPerson = observations.max(by: { $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height }) {
                    let centerX = largestPerson.boundingBox.midX
                    print("[ReframePlayer] Detected person at x: \(centerX)")
                    continuation.resume(returning: centerX)
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

    /// ソース動画の表示幅を計算
    private func calculateSourceWidth(containerSize: CGSize) -> CGFloat {
        guard let currentItem = player.currentItem else {
            // デフォルトで16:9を仮定
            return containerSize.height * (16.0 / 9.0)
        }

        let videoSize = currentItem.presentationSize
        guard videoSize.height > 0 else {
            return containerSize.height * (16.0 / 9.0)
        }

        // 動画のアスペクト比を使用
        let videoAspectRatio = videoSize.width / videoSize.height
        return containerSize.height * videoAspectRatio
    }

    /// パンオフセットを計算
    private func calculateOffset(containerSize: CGSize) -> CGFloat {
        let sourceWidth = calculateSourceWidth(containerSize: containerSize)
        let excessWidth = sourceWidth - containerSize.width

        guard excessWidth > 0 else { return 0 }

        // panOffset（-1.0〜1.0）をピクセルオフセットに変換
        // panOffset = 1.0 のとき左端、-1.0 のとき右端
        return -panOffset * excessWidth / 2
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
