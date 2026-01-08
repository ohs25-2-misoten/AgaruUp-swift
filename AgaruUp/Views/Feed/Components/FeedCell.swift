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
    
    /// 再生アイコンの表示状態（タップして再生したときに短時間表示される）
    @State private var showPlayIcon = false
    
    /// 動画の一時停止状態（一時停止中は一時停止アイコンが表示される）
    @State private var isPaused = false
    
    /// 動画のローディング状態（バッファリング中にスピナーを表示）
    @State private var isLoadingVideo = false
    
    /// ループ再生時のアイコン表示状態
    @State private var showLoopIcon = false
    
    /// 詳細表示の状態
    @State private var showDetails = false
    
    /// 再生アイコンを自動で非表示にするための非同期タスク
    /// タップ時に新しいタスクを開始し、前のタスクはキャンセルされる
    /// ビュー破棄時に適切にキャンセルしてリソースリークを防止
    @State private var playIconTask: Task<Void, Never>?
    
    /// ループアイコンを自動で非表示にするための非同期タスク
    @State private var loopIconTask: Task<Void, Never>?
    
    /// プレイヤーのローディング状態を監視するタイマーの購読
    /// onAppearで開始し、onDisappearでキャンセルしてリソースリークを防止
    @State private var timerCancellable: AnyCancellable?
    
    /// ループ再生監視用のCancellable
    @State private var loopCancellable: AnyCancellable?
    
    /// currentItemの変更監視用のCancellable
    @State private var currentItemCancellable: AnyCancellable?

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
                
                if showLoopIcon {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPaused)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showPlayIcon)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showLoopIcon)

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
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.headline)
                            .lineLimit(showDetails ? nil : 2)
                        
                        if showDetails {
                            // タグ表示（タグがある場合のみ）
                            if !video.tags.isEmpty {
                                FlowLayout(spacing: 6) {
                                    ForEach(video.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.2))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.top, 4)
                            } else {
                                Text("タグなし")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.top, 4)
                            }
                        }
                        
                        if let date = video.generatedAt {
                            Text(formatDate(date))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDetails.toggle()
                        }
                    }

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
            // タイマーが未起動の場合のみ購読を開始
            if timerCancellable == nil {
                timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        isLoadingVideo = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                        // プレイヤーの一時停止状態を監視（別タブ遷移時にも反映）
                        let playerPaused = player.timeControlStatus == .paused
                        if isPaused != playerPaused {
                            isPaused = playerPaused
                        }
                    }
            }
            
            // ループ再生の設定
            player.actionAtItemEnd = .none
            
            // 既存の購読をキャンセルしてから新しい購読を設定
            currentItemCancellable?.cancel()
            loopCancellable?.cancel()
            
            // currentItemの変更を監視してループ再生を再設定
            currentItemCancellable = player.publisher(for: \.currentItem)
                .sink { [self] newItem in
                    // 古い購読をキャンセル
                    loopCancellable?.cancel()
                    
                    guard let item = newItem else { return }
                    
                    loopCancellable = NotificationCenter.default.publisher(
                        for: .AVPlayerItemDidPlayToEndTime,
                        object: item
                    )
                    .sink { [self] _ in
                        player.seek(to: .zero)
                        player.play()
                        
                        // ループアイコンを表示
                        showLoopIcon = true
                        loopIconTask?.cancel()
                        loopIconTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            if !Task.isCancelled {
                                await MainActor.run { showLoopIcon = false }
                            }
                        }
                    }
                }
        }
        .onDisappear {
            // ビュー破棄時にTaskをキャンセル
            playIconTask?.cancel()
            playIconTask = nil
            
            // ループアイコンTaskをキャンセル
            loopIconTask?.cancel()
            loopIconTask = nil
            
            // タイマーの購読をキャンセル
            timerCancellable?.cancel()
            timerCancellable = nil
            
            // currentItem監視をキャンセル
            currentItemCancellable?.cancel()
            currentItemCancellable = nil
            
            // ループ再生の監視を解除
            loopCancellable?.cancel()
            loopCancellable = nil
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
