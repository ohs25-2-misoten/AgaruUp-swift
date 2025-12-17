//
//  FeedCell.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/17.
//

import AVKit
import Combine
import SwiftUI

struct FeedCell: View {
    let video: Video
    var player: AVPlayer

    @State private var isFavorite = false
    @State private var isAnimating = false
    @State private var heartPressed = false
    @State private var commentPressed = false
    @State private var showPlayIcon = false
    @State private var isPaused = false
    @State private var isLoadingVideo = false
    @State private var playIconTask: Task<Void, Never>?
    @State private var timerCancellable: Cancellable?

    /// プレイヤー状態監視用のタイマー (Combineベース)
    private let playerStatusTimer = Timer.publish(every: 0.1, on: .main, in: .common)

    private let favoriteService = FavoriteService.shared

    var body: some View {
        ZStack {
            CustomVideoPlayer(player: player)
                .containerRelativeFrame([.horizontal, .vertical])

            // 一時停止/再生マークの表示
            ZStack {
                if isPaused {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.scale.combined(with: .opacity))
                }

                if showPlayIcon {
                    Image(systemName: "play.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPaused)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showPlayIcon)

            // ローディングスピナー
            if isLoadingVideo {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 80, height: 80)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.headline)
                            .lineLimit(2)
                        if let date = video.generatedAt {
                            Text(formatDate(date))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.white)

                    Spacer()

                    VStack(spacing: 28) {
                        Button {
                            handleFavoriteTap()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(isFavorite ? .red : .white)
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(heartPressed ? 0.3 : 0.0))
                        )
                        .contentShape(Circle())
                        .pressEvents(
                            onPress: { heartPressed = true },
                            onRelease: { heartPressed = false }
                        )

                        Button {} label: {
                            Image(systemName: "ellipsis.bubble.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
										  .foregroundStyle(.gray)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(commentPressed ? 0.3 : 0.0))
                        )
                        .contentShape(Circle())
                        .pressEvents(
                            onPress: { commentPressed = true },
                            onRelease: { commentPressed = false }
                        )
								.disabled(true)
                    }
                }
                .padding(.bottom, 80)
            }
            .padding()
        }
        .onTapGesture {
            switch player.timeControlStatus {
            case .paused:
                player.play()
                isPaused = false
                showPlayIcon = true
                // 既存のTaskをキャンセルして新しいTaskを開始
                playIconTask?.cancel()
                playIconTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    // キャンセルされていなければ更新
                    if !Task.isCancelled {
                        await MainActor.run { showPlayIcon = false }
                    }
                }
            case .waitingToPlayAtSpecifiedRate:
                break
            case .playing:
                player.pause()
                isPaused = true
            @unknown default:
                break
            }
        }
        .task {
            await loadFavoriteStatus()
        }
        .onAppear {
            // タイマーを開始してCancellableを保存
            timerCancellable = playerStatusTimer.autoconnect().sink { _ in
                isLoadingVideo = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
            }
        }
        .onDisappear {
            // ビュー破棄時にTaskをキャンセル
            playIconTask?.cancel()
            playIconTask = nil
            
            // タイマーの購読をキャンセル
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    @MainActor
    private func loadFavoriteStatus() async {
        do {
            isFavorite = try favoriteService.isFavorite(movieId: video.movieId)
        } catch {
            print("お気に入り状態の読み込みエラー: \(error)")
        }
    }

    @MainActor
    private func handleFavoriteTap() {
        Task {
            do {
                let newState = try favoriteService.toggleFavorite(movieId: video.movieId)
                isFavorite = newState

                // アニメーション
                isAnimating = true
                try? await Task.sleep(nanoseconds: 300_000_000)
                isAnimating = false
            } catch {
                print("お気に入りの切り替えエラー: \(error)")
            }
        }
    }
}

// MARK: - View Extension for Press Events

extension View {
    /// ボタンの押下状態を検知するModifier
    /// - Parameters:
    ///   - onPress: ボタン押下時のコールバック
    ///   - onRelease: ボタン解放時のコールバック
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressModifier(onPress: onPress, onRelease: onRelease))
    }
}

private struct PressModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}
