//
//  APIEndpoint.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIEndpoint {
    // MARK: - Authentication
    case register
    case login
    case logout
    case refreshToken
    case forgotPassword
    case resetPassword
    
    // MARK: - Restaurants
    case restaurants(filters: RestaurantFilters?)
    case restaurantDetail(id: Int)
    case chainRestaurants
    case searchRestaurants(query: String)
    case nearbyRestaurants(latitude: Double, longitude: Double, radius: Double)
    
    // MARK: - Favorites
    case favorites
    case addFavorite(restaurantId: Int)
    case removeFavorite(restaurantId: Int)
    
    // MARK: - Reviews
    case reviews(restaurantId: Int)
    case addReview(restaurantId: Int)
    case updateReview(reviewId: Int)
    case deleteReview(reviewId: Int)
    
    // MARK: - User
    case profile
    case updateProfile
    case changePassword
    case deleteAccount
    
    // MARK: - Computed Properties
    var path: String {
        switch self {
        // Authentication
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .resetPassword:
            return "/auth/reset-password"
            
        // Restaurants
        case .restaurants:
            return "/restaurants"
        case .restaurantDetail(let id):
            return "/restaurants/\(id)"
        case .chainRestaurants:
            return "/restaurants/chains"
        case .searchRestaurants:
            return "/restaurants/search"
        case .nearbyRestaurants:
            return "/restaurants/nearby"
            
        // Favorites
        case .favorites:
            return "/favorites"
        case .addFavorite(let restaurantId):
            return "/favorites/\(restaurantId)"
        case .removeFavorite(let restaurantId):
            return "/favorites/\(restaurantId)"
            
        // Reviews
        case .reviews(let restaurantId):
            return "/restaurants/\(restaurantId)/reviews"
        case .addReview(let restaurantId):
            return "/restaurants/\(restaurantId)/reviews"
        case .updateReview(let reviewId):
            return "/reviews/\(reviewId)"
        case .deleteReview(let reviewId):
            return "/reviews/\(reviewId)"
            
        // User
        case .profile:
            return "/users/profile"
        case .updateProfile:
            return "/users/profile"
        case .changePassword:
            return "/users/change-password"
        case .deleteAccount:
            return "/users/account"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .register, .login, .forgotPassword, .resetPassword, .addFavorite, .addReview:
            return .post
        case .logout, .updateProfile, .updateReview:
            return .put
        case .changePassword:
            return .patch
        case .removeFavorite, .deleteReview, .deleteAccount:
            return .delete
        default:
            return .get
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .register, .login, .forgotPassword, .resetPassword:
            return false
        default:
            return true
        }
    }
    
    // Query parametreleri için
    func queryItems() -> [URLQueryItem]? {
        switch self {
        case .restaurants(let filters):
            guard let filters = filters else { return nil }
            var items: [URLQueryItem] = []
            
            if let city = filters.city {
                items.append(URLQueryItem(name: "city", value: city))
            }
            if let cuisineType = filters.cuisineType {
                items.append(URLQueryItem(name: "cuisine_type", value: cuisineType))
            }
            if let minRating = filters.minRating {
                items.append(URLQueryItem(name: "min_rating", value: "\(minRating)"))
            }
            if let maxDistance = filters.maxDistance {
                items.append(URLQueryItem(name: "max_distance", value: "\(maxDistance)"))
            }
            if let isChain = filters.isChain {
                items.append(URLQueryItem(name: "is_chain", value: "\(isChain)"))
            }
            
            return items.isEmpty ? nil : items
            
        case .searchRestaurants(let query):
            return [URLQueryItem(name: "q", value: query)]
            
        case .nearbyRestaurants(let latitude, let longitude, let radius):
            return [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
                URLQueryItem(name: "radius", value: "\(radius)")
            ]
            
        default:
            return nil
        }
    }
}

// MARK: - Restaurant Filters Model
struct RestaurantFilters {
    var city: String?
    var cuisineType: String?
    var minRating: Double?
    var maxDistance: Double?
    var isChain: Bool?
    
    init(city: String? = nil,
         cuisineType: String? = nil,
         minRating: Double? = nil,
         maxDistance: Double? = nil,
         isChain: Bool? = nil) {
        self.city = city
        self.cuisineType = cuisineType
        self.minRating = minRating
        self.maxDistance = maxDistance
        self.isChain = isChain
    }
}
