//
//  EnvironmentTests.swift
//  AgaruUpTests
//
//  Created by copilot on 2025/12/01.
//

import Testing
@testable import AgaruUp

struct EnvironmentTests {

    @Test func debugEnvironmentReturnsCorrectBaseURL() {
        let environment = Environment.Debug
        #expect(environment.baseUrl == "https://19977319-b30f-4d03-9b7b-6a9c89b89635.mock.pstmn.io")
    }

    @Test func stagingEnvironmentReturnsCorrectBaseURL() {
        let environment = Environment.Staging
        #expect(environment.baseUrl == "https://19977319-b30f-4d03-9b7b-6a9c89b89635.mock.pstmn.io")
    }

    @Test func releaseEnvironmentReturnsCorrectBaseURL() {
        let environment = Environment.Release
        #expect(environment.baseUrl == "https://agaruup-backend.kosuke.dev")
    }

    @Test func environmentRawValueInitialization() {
        #expect(Environment(rawValue: "Debug") == .Debug)
        #expect(Environment(rawValue: "Staging") == .Staging)
        #expect(Environment(rawValue: "Release") == .Release)
    }

    @Test func invalidEnvironmentRawValueReturnsNil() {
        #expect(Environment(rawValue: "Invalid") == nil)
        #expect(Environment(rawValue: "") == nil)
    }
}
