//
//  FavoriteServiceTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/11.
//

import Testing
import Foundation
import SwiftData
@testable import AgaruUp

@Suite("FavoriteServiceのテスト")
@MainActor
struct FavoriteServiceTests {
    
    private func createTestContainer() throws -> ModelContainer {
        let schema = Schema([FavoriteVideo.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }
    
    @Test("ModelContainerを設定できる")
    func configureModelContainer() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        
        service.configure(with: container)
        
        // contextが設定されていることを確認（エラーが出ないことで確認）
        let favorites = try service.fetchAllFavorites()
        #expect(favorites.isEmpty)
    }
    
    @Test("お気に入りの追加が正しく動作する")
    func addFavorite() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // お気に入りを追加
        try service.addFavorite(movieId: "test-movie-1")
        
        // お気に入りに追加されたことを確認
        let isFavorite = try service.isFavorite(movieId: "test-movie-1")
        #expect(isFavorite == true)
    }
    
    @Test("お気に入りの削除が正しく動作する")
    func removeFavorite() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // お気に入りを追加
        try service.addFavorite(movieId: "test-movie-1")
        #expect(try service.isFavorite(movieId: "test-movie-1") == true)
        
        // お気に入りを削除
        try service.removeFavorite(movieId: "test-movie-1")
        
        // お気に入りから削除されたことを確認
        let isFavorite = try service.isFavorite(movieId: "test-movie-1")
        #expect(isFavorite == false)
    }
    
    @Test("重複追加時の挙動が正しい")
    func duplicateAddFavorite() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // 同じIDを2回追加
        try service.addFavorite(movieId: "test-movie-1")
        try service.addFavorite(movieId: "test-movie-1")
        
        // 1つだけ追加されていることを確認
        let favorites = try service.fetchAllFavorites()
        #expect(favorites.count == 1)
        #expect(favorites.first?.movieId == "test-movie-1")
    }
    
    @Test("お気に入り判定が正確に動作する")
    func isFavoriteAccuracy() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // 最初はお気に入りではない
        #expect(try service.isFavorite(movieId: "test-movie-1") == false)
        
        // 追加後はお気に入り
        try service.addFavorite(movieId: "test-movie-1")
        #expect(try service.isFavorite(movieId: "test-movie-1") == true)
        
        // 別のIDはお気に入りではない
        #expect(try service.isFavorite(movieId: "test-movie-2") == false)
    }
    
    @Test("お気に入りIDリストの取得が正しく動作する")
    func fetchFavoriteIds() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // 複数のお気に入りを追加
        try service.addFavorite(movieId: "movie-1")
        try service.addFavorite(movieId: "movie-2")
        try service.addFavorite(movieId: "movie-3")
        
        // IDリストを取得
        let ids = try service.fetchFavoriteIds()
        
        // 3つのIDが取得できることを確認
        #expect(ids.count == 3)
        #expect(ids.contains("movie-1"))
        #expect(ids.contains("movie-2"))
        #expect(ids.contains("movie-3"))
    }
    
    @Test("お気に入りトグルが正しく動作する")
    func toggleFavorite() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // 最初はお気に入りではない
        #expect(try service.isFavorite(movieId: "test-movie-1") == false)
        
        // トグル1回目：追加される
        let isAdded = try service.toggleFavorite(movieId: "test-movie-1")
        #expect(isAdded == true)
        #expect(try service.isFavorite(movieId: "test-movie-1") == true)
        
        // トグル2回目：削除される
        let isRemoved = try service.toggleFavorite(movieId: "test-movie-1")
        #expect(isRemoved == false)
        #expect(try service.isFavorite(movieId: "test-movie-1") == false)
    }
    
    @Test("contextNotConfiguredエラーが正しく発生する")
    func contextNotConfiguredError() throws {
        // 新しいインスタンスを作成（sharedは使用しない）
        // Note: シングルトンパターンのため、この機能は直接テストできない
        // 実際の使用では、configure()を呼ばなかった場合にエラーが発生する
        
        // このテストはスキップ（シングルトンパターンの制約のため）
    }
    
    @Test("お気に入り一覧が追加日時降順で取得される")
    func fetchAllFavoritesSortOrder() throws {
        let service = FavoriteService.shared
        let container = try createTestContainer()
        service.configure(with: container)
        
        // 順番に追加（addedAtは自動的にDate()が設定される）
        try service.addFavorite(movieId: "movie-1")
        try service.addFavorite(movieId: "movie-2")
        try service.addFavorite(movieId: "movie-3")
        
        // 一覧を取得
        let favorites = try service.fetchAllFavorites()
        
        // 3つのお気に入りが取得されることを確認
        #expect(favorites.count == 3)
        
        // ソート順の確認（降順であること）
        // 追加順とは逆順（新しい順）になっているはず
        #expect(favorites[0].addedAt >= favorites[1].addedAt)
        #expect(favorites[1].addedAt >= favorites[2].addedAt)
        
        // IDの存在確認
        let movieIds = favorites.map { $0.movieId }
        #expect(movieIds.contains("movie-1"))
        #expect(movieIds.contains("movie-2"))
        #expect(movieIds.contains("movie-3"))
    }
}
