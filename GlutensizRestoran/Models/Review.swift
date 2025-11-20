//
//  Review.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

// MARK: - Review Model
struct Review: Codable, Identifiable {
    let id: Int
    let restaurantId: Int
    let userId: Int
    let userName: String
    let userAvatar: String?
    let rating: Double
    let title: String?
    let comment: String
    let visitDate: Date?
    let photos: [String]?
    let isVerified: Bool
    let helpfulCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    // Computed properties
    var displayRating: String {
        String(format: "%.1f", rating)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var visitDateText: String? {
        guard let visitDate = visitDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        return "Ziyaret: " + formatter.string(from: visitDate)
    }
    
    var hasPhotos: Bool {
        photos?.isEmpty == false
    }
    
    var photoCount: Int {
        photos?.count ?? 0
    }
}

// MARK: - Add Review Request
struct AddReviewRequest: Encodable {
    let restaurantId: Int
    let rating: Double
    let title: String?
    let comment: String
    let visitDate: Date?
    let photos: [String]?
}

// MARK: - Update Review Request
struct UpdateReviewRequest: Encodable {
    let rating: Double?
    let title: String?
    let comment: String?
    let visitDate: Date?
}

// MARK: - Review Response Models
struct ReviewsResponse: Decodable {
    let reviews: [Review]
    let total: Int
    let averageRating: Double
    let ratingDistribution: RatingDistribution?
}

struct RatingDistribution: Decodable {
    let fiveStars: Int
    let fourStars: Int
    let threeStars: Int
    let twoStars: Int
    let oneStar: Int
    
    var total: Int {
        fiveStars + fourStars + threeStars + twoStars + oneStar
    }
    
    func percentage(for rating: Int) -> Double {
        guard total > 0 else { return 0 }
        let count: Int
        switch rating {
        case 5: count = fiveStars
        case 4: count = fourStars
        case 3: count = threeStars
        case 2: count = twoStars
        case 1: count = oneStar
        default: count = 0
        }
        return (Double(count) / Double(total)) * 100
    }
}

// MARK: - Add Review Response
struct AddReviewResponse: Decodable {
    let review: Review
    let message: String?
}

// MARK: - Helpful Review Request
struct MarkReviewHelpfulRequest: Encodable {
    let reviewId: Int
    let isHelpful: Bool
}
