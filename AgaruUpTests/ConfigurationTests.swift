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

    // MARK: - Tests for environment(from:) method

    @Test func environmentWithDebugConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Debug"])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == .Debug)
    }

    @Test func environmentWithStagingConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Staging"])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == .Staging)
    }

    @Test func environmentWithReleaseConfiguration() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Release"])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == .Release)
    }

    @Test func environmentWithInvalidConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": "Invalid"])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == nil)
    }

    @Test func environmentWithEmptyConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": ""])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == nil)
    }

    @Test func environmentWithMissingConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: [:])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == nil)
    }

    @Test func environmentWithWrongTypeConfigurationReturnsNil() {
        let mockProvider = MockInfoDictionaryProvider(infoDictionary: ["APIConfiguration": 123])
        let environment = Configuration.environment(from: mockProvider)
        #expect(environment == nil)
    }
}
