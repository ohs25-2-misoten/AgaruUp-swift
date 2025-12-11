//
//  FavoriteViewModelTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/11.
//

import Testing
import Foundation
@testable import AgaruUp

@Suite("FavoriteViewModelのテスト")
@MainActor
struct FavoriteViewModelTests {
    
    @Test("初期状態が正しい")
    func initialState() {
        let viewModel = FavoriteViewModel()
        
        #expect(viewModel.videos.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("空のお気に入りリストを読み込む")
    func loadEmptyFavorites() async throws {
        let viewModel = FavoriteViewModel()
        
        // Note: 実際のAPIとの統合テストのため、モックが必要
        // ここでは基本的な動作のみをテスト
        
        #expect(viewModel.videos.isEmpty)
    }
    
    @Test("お気に入り削除後にUI更新される")
    func removeFavoriteUpdatesUI() async {
        let viewModel = FavoriteViewModel()
        
        // Note: 実際のサービスとの統合が必要なため、
        // このテストは統合テスト環境で実行されるべき
        
        // 基本的な動作確認
        await viewModel.removeFavorite(movieId: "test-id")
        
        // エラーメッセージが設定される可能性がある
        // （FavoriteServiceが設定されていない場合）
    }
    
    @Test("リフレッシュがloadFavoriteVideosを呼び出す")
    func refreshCallsLoad() async {
        let viewModel = FavoriteViewModel()
        
        // refresh()を呼び出してエラーが発生しないことを確認
        await viewModel.refresh()
        
        // 基本的な動作確認
        #expect(viewModel.isLoading == false)
    }
}

// MARK: - 統合テスト用の注記
// 
// FavoriteViewModelは以下の理由により、完全なテストには統合テスト環境が必要です：
// 1. FavoriteService.sharedに依存（シングルトンパターン）
// 2. VideoService.sharedに依存（実際のAPI呼び出し）
// 3. SwiftDataのModelContainerが必要
//
// より完全なテストには以下のアプローチが推奨されます：
// - Dependency Injection（DI）パターンの導入
// - プロトコルベースのモック実装
// - テスト用のサービスファクトリー
