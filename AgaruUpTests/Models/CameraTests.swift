//
//  CameraTests.swift
//  AgaruUpTests
//
//  Created on 2025/12/08.
//

import Testing
import Foundation
@testable import AgaruUp

@Suite("Cameraモデルのテスト")
struct CameraTests {
    
    @Test("JSONからCameraモデルをデコードできる")
    nonisolated func decodeFromJSON() throws {
        let json = """
        {
            "name": "大阪駅カメラ1",
            "id": "camera-uuid-123",
            "coordinate": {
                "lat": 34.7024,
                "lng": 135.4959
            },
            "url": "https://example.com/camera/1"
        }
        """.data(using: .utf8)!
        
        let camera = try JSONDecoder().decode(Camera.self, from: json)
        
        #expect(camera.name == "大阪駅カメラ1")
        #expect(camera.id == "camera-uuid-123")
        #expect(camera.coordinate.lat == 34.7024)
        #expect(camera.coordinate.lng == 135.4959)
        #expect(camera.url == "https://example.com/camera/1")
    }
    
    @Test("Coordinateモデルが正しくデコードされる")
    nonisolated func coordinateDecoding() throws {
        let json = """
        {
            "lat": 35.6812,
            "lng": 139.7671
        }
        """.data(using: .utf8)!
        
        let coordinate = try JSONDecoder().decode(Coordinate.self, from: json)
        
        #expect(coordinate.lat == 35.6812)
        #expect(coordinate.lng == 139.7671)
    }
}
