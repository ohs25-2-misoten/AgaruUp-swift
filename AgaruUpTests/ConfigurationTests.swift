//
//  ConfigurationTests.swift
//  AgaruUpTests
//
//  Created by copilot on 2025/12/01.
//

import Testing
import Foundation
@testable import AgaruUp

/// Mock provider for testing Configuration with various Info.plist values
struct MockInfoDictionaryProvider: InfoDictionaryProvider {
    private var infoDictionary: [String: Any]
    
    init(infoDictionary: [String: Any]) {
        self.infoDictionary = infoDictionary
    }
    
    func object(forInfoDictionaryKey key: String) -> Any? {
        return infoDictionary[key]
    }
}

struct ConfigurationTests {
    
    // MARK: - Tests for getEnvironment(from:) method
    
    @Test func getEnvironmentWithDebugConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Debug"])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == .Debug)
    }
    
    @Test func getEnvironmentWithStagingConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Staging"])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == .Staging)
    }
    
    @Test func getEnvironmentWithReleaseConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Release"])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == .Release)
    }
    
    @Test func getEnvironmentWithInvalidConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Invalid"])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == nil)
    }
    
    @Test func getEnvironmentWithEmptyConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": ""])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == nil)
    }
    
    @Test func getEnvironmentWithMissingConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: [:])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == nil)
    }
    
    @Test func getEnvironmentWithWrongTypeConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": 123])
        let environment = Configuration.getEnvironment(from: mockProvider)
        #expect(environment == nil)
    }
}
