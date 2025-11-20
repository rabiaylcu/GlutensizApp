//
//  Components.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import SwiftUI

// MARK: - Restaurant Card Component
struct RestaurantCard: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Restaurant Image
            if let imageUrl = restaurant.displayImage {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fill)
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .frame(maxWidth: .infinity)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    // Rating
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(restaurant.displayRating)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                    
                    Text("• \(restaurant.cuisineTypesString)")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                // Distance (if available)
                if let _ = restaurant.location {
                    Text("Yakınınızda")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(16)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.5)
            
            Text("Yükleniyor...")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Ara..."
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.backgroundSecondary)
        .cornerRadius(12)
    }
}

// MARK: - Preview
#if DEBUG
struct Components_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RestaurantCard(restaurant: sampleRestaurant)
                .padding()
            
            SearchBar(text: .constant(""))
                .padding()
        }
    }
}
#endif
