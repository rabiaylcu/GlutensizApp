//
//  Restaurant.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import CoreLocation

// MARK: - Restaurant Model
struct Restaurant: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let address: String
    let city: String?
    let district: String?
    let latitude: Double?
    let longitude: Double?
    let phoneNumber: String?
    let phone: String?
    let email: String?
    let website: String?
    let imageUrl: String?
    let image: String?
    let images: [String]?
    let cuisineTypes: [String]?
    let isChain: Bool?
    let chainName: String?
    let averageRating: Double?
    let rating: Double?
    let reviewCount: Int?
    let priceRange: PriceRange?
    let openingHours: [OpeningHour]?
    let features: [String]?
    let createdAt: Date?
    let updatedAt: Date?
    let distanceKm: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, address, city, district
        case latitude, longitude
        case phoneNumber = "phone_number"
        case phone
        case email, website
        case imageUrl = "image_url"
        case image
        case images
        case cuisineTypes = "cuisine_types"
        case isChain = "is_chain"
        case chainName = "chain_name"
        case averageRating = "average_rating"
        case rating
        case reviewCount = "review_count"
        case priceRange = "price_range"
        case openingHours = "opening_hours"
        case features
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case distanceKm = "distance_km"
    }
    
    // Computed properties
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    var fullAddress: String {
        var parts: [String] = [address]
        if let district = district { parts.append(district) }
        if let city = city { parts.append(city) }
        return parts.joined(separator: ", ")
    }
    
    var cuisineTypesString: String {
        cuisineTypes?.joined(separator: ", ") ?? "Mutfak bilgisi yok"
    }
    
    var priceRangeSymbol: String {
        guard let range = priceRange else { return "₺" }
        return String(repeating: "₺", count: range.rawValue)
    }
    
    var displayRating: String {
        let ratingValue = rating ?? averageRating ?? 0.0
        return String(format: "%.1f", ratingValue)
    }
    
    var reviewCountText: String {
        guard let count = reviewCount else { return "Henüz değerlendirme yok" }
        if count == 0 {
            return "Henüz değerlendirme yok"
        } else if count == 1 {
            return "1 değerlendirme"
        } else {
            return "\(count) değerlendirme"
        }
    }
    
    var displayImage: String? {
        return image ?? imageUrl
    }
    
    var displayPhone: String? {
        return phone ?? phoneNumber
    }
}

// MARK: - Price Range
enum PriceRange: Int, Codable {
    case budget = 1
    case moderate = 2
    case expensive = 3
    case luxury = 4
    
    var description: String {
        switch self {
        case .budget:
            return "Ekonomik"
        case .moderate:
            return "Orta"
        case .expensive:
            return "Pahalı"
        case .luxury:
            return "Lüks"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = PriceRange(rawValue: intValue) ?? .moderate
        } else if let stringValue = try? container.decode(String.self), let intValue = Int(stringValue) {
            self = PriceRange(rawValue: intValue) ?? .moderate
        } else {
            self = .moderate
        }
    }
}

// MARK: - Opening Hours
struct OpeningHour: Codable {
    let dayOfWeek: Int // 0 = Pazar, 1 = Pazartesi, ..., 6 = Cumartesi
    let openTime: String // "09:00"
    let closeTime: String // "22:00"
    let isClosed: Bool
    
    var dayName: String {
        let days = ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
        return days[dayOfWeek]
    }
    
    var hoursText: String {
        if isClosed {
            return "Kapalı"
        }
        return "\(openTime) - \(closeTime)"
    }
}

// MARK: - Restaurant Detail (Extended)
struct RestaurantDetail: Codable, Identifiable {
    let id: Int
    let restaurant: Restaurant
    let menu: [MenuItem]?
    let photos: [Photo]?
    let recentReviews: [Review]?
    let isFavorite: Bool
    let distance: Double? // km cinsinden
    
    var distanceText: String? {
        guard let distance = distance else { return nil }
        if distance < 1 {
            return String(format: "%.0f m", distance * 1000)
        }
        return String(format: "%.1f km", distance)
    }
}

// MARK: - Menu Item
struct MenuItem: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let price: Double?
    let category: String
    let imageUrl: String?
    let isGlutenFree: Bool
    let isVegan: Bool?
    let isVegetarian: Bool?
    let allergens: [String]?
    
    var priceText: String? {
        guard let price = price else { return nil }
        return String(format: "%.2f ₺", price)
    }
}

// MARK: - Photo
struct Photo: Codable, Identifiable {
    let id: Int
    let url: String
    let caption: String?
    let uploadedBy: String?
    let uploadedAt: Date
}

// MARK: - Chain Restaurant
struct ChainRestaurant: Codable, Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?
    let description: String?
    let totalLocations: Int
    let averageRating: Double
    let locations: [Restaurant]?
}

// MARK: - Restaurant Response Models
struct RestaurantsResponse: Decodable {
    let restaurants: [Restaurant]
    let total: Int?
    let page: Int?
    let pageSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case restaurants
        case total
        case page
        case pageSize = "page_size"
    }
    
    // Backend sadece array dönüyorsa
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.restaurants = try container.decode([Restaurant].self, forKey: .restaurants)
            self.total = try container.decodeIfPresent(Int.self, forKey: .total)
            self.page = try container.decodeIfPresent(Int.self, forKey: .page)
            self.pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
        } else {
            // Backend direkt array dönüyorsa
            let container = try decoder.singleValueContainer()
            self.restaurants = try container.decode([Restaurant].self)
            self.total = nil
            self.page = nil
            self.pageSize = nil
        }
    }
}

struct RestaurantDetailResponse: Decodable {
    let restaurant: RestaurantDetail
}

struct ChainRestaurantsResponse: Decodable {
    let chains: [ChainRestaurant]
}
