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
            let configuration = Bundle.main.object(forInfoDictionaryKey: "APIConfiguration") as! String
            return Environment(rawValue: configuration)!
        }
    }
}
