//
//  RequestModelsTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/08.
//

import Testing
import Foundation
@testable import AgaruUp

@Suite("リクエストモデルのテスト")
struct RequestModelsTests {
    
    // MARK: - ReportRequest Tests
    
    @Test("ReportRequestを正しくエンコードできる")
    nonisolated func encodeReportRequest() throws {
        let request = ReportRequest(user: "user-uuid-123", location: "camera-uuid-456")
        
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        #expect(json["user"] as? String == "user-uuid-123")
        #expect(json["location"] as? String == "camera-uuid-456")
    }
    
    @Test("ReportRequestをデコードできる")
    nonisolated func decodeReportRequest() throws {
        let json = """
        {
            "user": "user-abc",
            "location": "loc-xyz"
        }
        """.data(using: .utf8)!
        
        let request = try JSONDecoder().decode(ReportRequest.self, from: json)
        
        #expect(request.user == "user-abc")
        #expect(request.location == "loc-xyz")
    }
    
    // MARK: - BulkVideosRequest Tests
    
    @Test("BulkVideosRequestを正しくエンコードできる")
    nonisolated func encodeBulkVideosRequest() throws {
        let request = BulkVideosRequest(videos: ["video-1", "video-2", "video-3"])
        
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let videos = json["videos"] as? [String]
        #expect(videos == ["video-1", "video-2", "video-3"])
    }
    
    @Test("空の配列でBulkVideosRequestを作成できる")
    nonisolated func emptyBulkVideosRequest() throws {
        let request = BulkVideosRequest(videos: [])
        
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let videos = json["videos"] as? [String]
        #expect(videos?.isEmpty == true)
    }
}
