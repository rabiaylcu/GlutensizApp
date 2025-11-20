//
//  NetworkManager.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import Combine

// MARK: - Network Manager Protocol
protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable?) async throws -> T
    func request(_ endpoint: APIEndpoint, body: Encodable?) async throws
}

// MARK: - Network Manager
final class NetworkManager: NetworkManagerProtocol {
    
    // Singleton instance
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Token yönetimi için
    private var accessToken: String? {
        get { KeychainManager.shared.get(key: Constants.StorageKeys.accessToken) }
        set {
            if let token = newValue {
                KeychainManager.shared.save(key: Constants.StorageKeys.accessToken, value: token)
            } else {
                KeychainManager.shared.delete(key: Constants.StorageKeys.accessToken)
            }
        }
    }
    
    private init() {
        // URLSession yapılandırması
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.timeoutInterval
        configuration.timeoutIntervalForResource = Constants.API.timeoutInterval
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        // JSON decoder yapılandırması
        self.decoder = JSONDecoder()
        // NOT: convertFromSnakeCase kullanmıyoruz, manuel CodingKeys ile yapıyoruz
        
        // Custom date decoding strategy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try with microseconds
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try ISO8601 formatter as fallback
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        // JSON encoder yapılandırması
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Public Methods
    
    /// Generic request metodu - response döndürür
    func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable? = nil) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, body: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Response validation
            try validateResponse(response, data: data)
            
            // Debug logging
            #if DEBUG
            logResponse(data: data, response: response, endpoint: endpoint)
            #endif
            
            // Decode response
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Decoding error: Key '\(key.stringValue)' not found")
                print("❌ Context: \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
                throw NetworkError.decodingError
            } catch let DecodingError.typeMismatch(type, context) {
                print("❌ Decoding error: Type mismatch for type \(type)")
                print("❌ Context: \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
                throw NetworkError.decodingError
            } catch let DecodingError.valueNotFound(type, context) {
                print("❌ Decoding error: Value not found for type \(type)")
                print("❌ Context: \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
                throw NetworkError.decodingError
            } catch let DecodingError.dataCorrupted(context) {
                print("❌ Decoding error: Data corrupted")
                print("❌ Context: \(context.debugDescription)")
                print("❌ Coding path: \(context.codingPath)")
                throw NetworkError.decodingError
            } catch {
                print("❌ Unknown decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw mapError(error)
        }
    }
    
    /// Request metodu - response döndürmez (logout, delete vs için)
    func request(_ endpoint: APIEndpoint, body: Encodable? = nil) async throws {
        let request = try buildRequest(endpoint: endpoint, body: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Response validation
            try validateResponse(response, data: data)
            
            // Debug logging
            #if DEBUG
            logResponse(data: data, response: response, endpoint: endpoint)
            #endif
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw mapError(error)
        }
    }
    
    // MARK: - Token Management
    
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    func clearTokens() {
        KeychainManager.shared.delete(key: Constants.StorageKeys.accessToken)
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(endpoint: APIEndpoint, body: Encodable?) throws -> URLRequest {
        // URL oluştur
        guard var urlComponents = URLComponents(string: Constants.API.baseURL + Constants.API.version + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        // Query parametrelerini ekle
        if let queryItems = endpoint.queryItems() {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // URLRequest oluştur
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Auth token ekle
        if endpoint.requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Body ekle
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        // Debug logging
        #if DEBUG
        logRequest(request, body: body)
        #endif
        
        return request
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401:
            // Token süresi dolmuş, kullanıcıyı login'e yönlendir
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 400...499:
            // Client error - backend'den gelen hata mesajını parse et
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknown(NSError(domain: "Unexpected status code", code: httpResponse.statusCode))
        }
    }
    
    private func mapError(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
    
    // MARK: - Debug Logging
    
    #if DEBUG
    private func logRequest(_ request: URLRequest, body: Encodable?) {
        print("\n🌐 ===== NETWORK REQUEST =====")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        if let body = body {
            if let jsonData = try? encoder.encode(body),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Body: \(jsonString)")
            }
        }
        print("=============================\n")
    }
    
    private func logResponse(data: Data, response: URLResponse, endpoint: APIEndpoint) {
        print("\n✅ ===== NETWORK RESPONSE =====")
        print("Endpoint: \(endpoint.path)")
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Response: \(jsonString)")
        }
        print("=============================\n")
    }
    #endif
}

// MARK: - Error Response Model
struct ErrorResponse: Decodable {
    let message: String
    let code: String?
    let details: [String: String]?
}
