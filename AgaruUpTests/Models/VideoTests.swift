//
//  VideoTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/08.
//

import Testing
import Foundation
@testable import AgaruUp

@Suite("Videoモデルのテスト")
struct VideoTests {
    
    @Test("JSONからVideoモデルをデコードできる")
    nonisolated func decodeFromJSON() throws {
        let json = """
        {
            "title": "テスト動画",
            "tags": ["大阪駅", "イベント"],
            "location": "camera-uuid-123",
            "generateDate": "2025-12-08T10:30:00Z",
            "baseUrl": "https://example.com/videos",
            "movieId": "movie-uuid-456"
        }
        """.data(using: .utf8)!
        
        let video = try JSONDecoder().decode(Video.self, from: json)
        
        #expect(video.title == "テスト動画")
        #expect(video.tags == ["大阪駅", "イベント"])
        #expect(video.location == "camera-uuid-123")
        #expect(video.generateDate == "2025-12-08T10:30:00Z")
        #expect(video.baseUrl == "https://example.com/videos")
        #expect(video.movieId == "movie-uuid-456")
    }
    
    @Test("VideoのidはmovieIdと同じ")
    nonisolated func idEqualsMovieId() throws {
        let json = """
        {
            "title": "テスト",
            "tags": [],
            "location": "loc",
            "generateDate": "2025-12-08T10:30:00Z",
            "baseUrl": "https://example.com",
            "movieId": "test-movie-id"
        }
        """.data(using: .utf8)!
        
        let video = try JSONDecoder().decode(Video.self, from: json)
        
        #expect(video.id == video.movieId)
        #expect(video.id == "test-movie-id")
    }
    
    @Test("videoUrlが正しく生成される")
    nonisolated func videoUrlGeneration() throws {
        let json = """
        {
            "title": "テスト",
            "tags": [],
            "location": "loc",
            "generateDate": "2025-12-08T10:30:00Z",
            "baseUrl": "https://example.com/videos",
            "movieId": "abc123"
        }
        """.data(using: .utf8)!
        
        let video = try JSONDecoder().decode(Video.self, from: json)
        
        #expect(video.videoUrl == "https://example.com/videos/abc123.mp4")
    }
}
