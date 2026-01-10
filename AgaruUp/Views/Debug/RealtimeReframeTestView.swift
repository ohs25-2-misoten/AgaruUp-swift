//
//  RealtimeReframeTestView.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVKit
import PhotosUI
import SwiftUI

/// リアルタイムリフレーム機能のテストビュー
struct RealtimeReframeTestView: View {
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let player = player {
                    // リアルタイムリフレームプレイヤー
                    VStack {
                        Text("リアルタイム追尾")
                            .font(.headline)

                        RealtimeReframeVideoPlayer(player: player)
                            .frame(width: 270, height: 480)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                    }

                    // 再生コントロール
                    HStack(spacing: 30) {
                        Button {
                            player.seek(to: .zero)
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }

                        Button {
                            if isPlaying {
                                player.pause()
                            } else {
                                player.play()
                            }
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                        }
                    }
                    .foregroundColor(.primary)
                    .padding()

                } else {
                    // 動画選択ボタン
                    PhotosPicker(
                        selection: $selectedVideoItem,
                        matching: .videos
                    ) {
                        VStack(spacing: 12) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)

                            Text("横長動画を選択")
                                .font(.headline)

                            Text("人物を自動追尾して縦長表示します")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                }

                // エラー表示
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()

                // リセットボタン
                if player != nil {
                    Button("別の動画を選択") {
                        resetState()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Realtime Reframe")
            .onChange(of: selectedVideoItem) { _, newItem in
                Task {
                    await loadVideo(from: newItem)
                }
            }
        }
    }

    /// 選択された動画を読み込む
    private func loadVideo(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "動画の読み込みに失敗しました"
                return
            }

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            try data.write(to: tempURL)

            await MainActor.run {
                videoURL = tempURL
                player = AVPlayer(url: tempURL)
                player?.play()
                isPlaying = true
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "動画の読み込みに失敗: \(error.localizedDescription)"
            }
        }
    }

    /// 状態をリセット
    private func resetState() {
        player?.pause()
        player = nil

        if let url = videoURL {
            try? FileManager.default.removeItem(at: url)
        }
        videoURL = nil
        selectedVideoItem = nil
        isPlaying = false
        errorMessage = nil
    }
}

#Preview {
    RealtimeReframeTestView()
}
