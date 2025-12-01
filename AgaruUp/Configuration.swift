//
//  Configuration.swift
//  AgaruUp
//
//  Created by kosukej on 2025/12/01.
//

import Foundation

struct Configuration {
    static var environment: Environment {
        get {
            guard let configuration = Bundle.main.object(forInfoDictionaryKey: "APIConfiguration") as? String,
            let env = Environment(rawValue: configuration) else {
                fatalError("APIConfiguration value is invalid")
            }
            return env
        }
    }
}
