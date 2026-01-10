//
//  AutoReframeTestView.swift
//  AgaruUp
//
//  Created on 2026/01/10.
//

import AVKit
import PhotosUI
import SwiftUI

/// 自動リフレーム機能のテストビュー
struct AutoReframeTestView: View {
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var inputVideoURL: URL?
    @State private var outputVideoURL: URL?
    @State private var player: AVPlayer?
    @State private var showingResult: Bool = false
    @State private var errorMessage: String?

    private let reframeService = VideoAutoReframeService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 入力動画プレビュー
                if let inputURL = inputVideoURL {
                    VStack {
                        Text("入力動画（横長）")
                            .font(.headline)

                        VideoPlayer(player: AVPlayer(url: inputURL))
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                } else {
                    // 動画選択ボタン
                    PhotosPicker(
                        selection: $selectedVideoItem,
                        matching: .videos
                    ) {
                        VStack(spacing: 12) {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)

                            Text("横長動画を選択")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }

                // 処理ボタン
                if inputVideoURL != nil && !reframeService.isProcessing {
                    Button {
                        Task {
                            await processVideo()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("縦長にリフレーム")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                }

                // 処理中の表示
                if reframeService.isProcessing {
                    VStack(spacing: 12) {
                        ProgressView(value: reframeService.progress)
                            .progressViewStyle(LinearProgressViewStyle())

                        Text("処理中... \(Int(reframeService.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                // エラー表示
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }

                // 出力動画プレビュー
                if let outputURL = outputVideoURL {
                    VStack {
                        Text("出力動画（縦長）")
                            .font(.headline)

                        VideoPlayer(player: AVPlayer(url: outputURL))
                            .frame(width: 180, height: 320)
                            .cornerRadius(12)
                    }
                }

                Spacer()

                // リセットボタン
                if inputVideoURL != nil {
                    Button("リセット") {
                        resetState()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Auto Reframe")
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
            // 動画データを取得
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "動画の読み込みに失敗しました"
                return
            }

            // 一時ファイルとして保存
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            try data.write(to: tempURL)

            await MainActor.run {
                inputVideoURL = tempURL
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "動画の読み込みに失敗しました: \(error.localizedDescription)"
            }
        }
    }

    /// 動画をリフレーム処理
    private func processVideo() async {
        guard let inputURL = inputVideoURL else { return }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reframed_\(UUID().uuidString)")
            .appendingPathExtension("mp4")

        do {
            try await reframeService.processVideo(inputURL: inputURL, outputURL: outputURL)

            await MainActor.run {
                self.outputVideoURL = outputURL
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "処理に失敗しました: \(error.localizedDescription)"
            }
        }
    }

    /// 状態をリセット
    private func resetState() {
        // 一時ファイルを削除
        if let inputURL = inputVideoURL {
            try? FileManager.default.removeItem(at: inputURL)
        }
        if let outputURL = outputVideoURL {
            try? FileManager.default.removeItem(at: outputURL)
        }

        inputVideoURL = nil
        outputVideoURL = nil
        selectedVideoItem = nil
        errorMessage = nil
    }
}

#Preview {
    AutoReframeTestView()
}
