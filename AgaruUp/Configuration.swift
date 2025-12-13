//
//  Configuration.swift
//  AgaruUp
//
//  Created by kosukej on 2025/12/01.
//

import Foundation

/// Protocol for reading Info.plist configuration values
protocol InfoDictionaryProvider {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: InfoDictionaryProvider {}

enum Configuration {
    static var environment: Environment {
        guard let env = environment(from: Bundle.main) else {
            fatalError("APIConfiguration value is invalid")
        }
        return env
    }

    /// Get environment from a provider (useful for testing)
    /// Returns nil if configuration is missing or invalid
    static func environment(from provider: InfoDictionaryProvider) -> Environment? {
        guard let configuration = provider.object(forInfoDictionaryKey: "APIConfiguration") as? String,
              let env = Environment(rawValue: configuration)
        else {
            return nil
        }
        return env
    }
}
