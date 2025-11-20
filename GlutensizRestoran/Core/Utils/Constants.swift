//
//  Constants.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

struct Constants {
    
    // MARK: - API Configuration
    struct API {
        // Backend arkadaşınızdan gelecek base URL
        // Development için localhost kullanılabilir
        static let baseURL = "http://localhost:8000" // GÜNCELLE: Production URL'i buraya yazın
        static let version = "/api/v1"
        
        // Timeout süreleri
        static let timeoutInterval: TimeInterval = 30
    }
    
    // MARK: - Storage Keys
    struct StorageKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let userID = "user_id"
        static let isLoggedIn = "is_logged_in"
        static let language = "app_language"
    }
    
    // MARK: - Map Configuration
    struct Map {
        static let defaultLatitude = 41.0082  // İstanbul
        static let defaultLongitude = 28.9784
        static let defaultSpan = 0.05
        static let maxSearchRadius = 50.0 // km
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let animationDuration: Double = 0.3
        static let maxImageSize: Int = 1024 * 1024 * 5 // 5MB
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 8
        static let maxPasswordLength = 128
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    // MARK: - App Info
    struct App {
        static let name = "Glutensiz Restoran"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
