//
//  Environment.swift
//  AgaruUp
//
//  Created by kosukej on 2025/12/01.
//

enum Environment: String {
    case Debug
    case Staging
    case Release
    
    var baseUrl: String {
        switch self {
        case .Debug: return "https://19977319-b30f-4d03-9b7b-6a9c89b89635.mock.pstmn.io"
        case .Staging: return "https://19977319-b30f-4d03-9b7b-6a9c89b89635.mock.pstmn.io"
        case .Release: return "https://agaruup-backend.kosuke.dev"
        }
    }
}
