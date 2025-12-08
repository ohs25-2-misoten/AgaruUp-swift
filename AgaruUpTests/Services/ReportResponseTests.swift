//
//  ReportResponseTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/08.
//

import Testing
import Foundation
@testable import AgaruUp

@Suite("ReportResponseモデルのテスト")
struct ReportResponseTests {
    
    @Test("完全なJSONからReportResponseをデコードできる")
    nonisolated func decodeFullResponse() throws {
        let json = """
        {
            "id": "report-123",
            "status": "success",
            "message": "報告を受け付けました"
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ReportResponse.self, from: json)
        
        #expect(response.id == "report-123")
        #expect(response.status == "success")
        #expect(response.message == "報告を受け付けました")
    }
    
    @Test("一部のフィールドがnullでもデコードできる")
    nonisolated func decodePartialResponse() throws {
        let json = """
        {
            "id": null,
            "status": "success",
            "message": null
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ReportResponse.self, from: json)
        
        #expect(response.id == nil)
        #expect(response.status == "success")
        #expect(response.message == nil)
    }
    
    @Test("フィールドが存在しなくてもデコードできる")
    nonisolated func decodeMinimalResponse() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ReportResponse.self, from: json)
        
        #expect(response.id == nil)
        #expect(response.status == nil)
        #expect(response.message == nil)
    }
}
