//
//  User.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let profileImageUrl: String?
    let preferredLanguage: String?
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case profileImageUrl = "profile_image_url"
        case preferredLanguage = "preferred_language"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return firstInitial + lastInitial
    }
}

// MARK: - Authentication Request Models
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let passwordConfirm: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case passwordConfirm = "password_confirm"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
    }
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ResetPasswordRequest: Encodable {
    let token: String
    let newPassword: String
}

struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
}

// MARK: - Authentication Response Models
struct LoginResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

struct RegisterResponse: Decodable {
    let message: String
    let user: User
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Profile Update Request
struct UpdateProfileRequest: Encodable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let profileImageUrl: String?
}
