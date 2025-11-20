//
//  Response.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

// MARK: - Generic API Response Wrapper
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: ErrorDetail?
}

// MARK: - Error Detail
struct ErrorDetail: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

// MARK: - Paginated Response
struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
    
    var hasNextPage: Bool {
        page < totalPages
    }
    
    var hasPreviousPage: Bool {
        page > 1
    }
}

// MARK: - Success Response
struct SuccessResponse: Decodable {
    let success: Bool
    let message: String
}

// MARK: - Empty Response (for delete, logout operations)
struct EmptyResponse: Decodable {
    let success: Bool
}
