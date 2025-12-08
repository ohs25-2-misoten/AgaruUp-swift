//
//  APIClient.swift
//  AgaruUp
//
//  Created on 2025/11/28.
//

import Foundation

/// APIエラー定義
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        case .decodingError(let error):
            return "データの解析に失敗しました: \(error.localizedDescription)"
        }
    }
}

/// シンプルなAPIクライアント
final class APIClient: Sendable {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        // info.plistから環境設定を取得
        self.baseURL = Configuration.environment.baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request
    
    /// 汎用的なGETリクエスト
    nonisolated func get<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// クエリパラメータ付きGETリクエスト
    nonisolated func get<T: Decodable>(_ endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        
        // 空でないクエリアイテムのみ追加
        let validQueryItems = queryItems.filter { $0.value != nil && !($0.value?.isEmpty ?? true) }
        if !validQueryItems.isEmpty {
            components?.queryItems = validQueryItems
        }
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// 汎用的なPOSTリクエスト
    nonisolated func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
