//
//  Extensions.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Brand Colors
    static let brandPrimary = Color("Primary") // Assets'te tanımlanacak
    static let brandSecondary = Color("Secondary")
    static let brandAccent = Color("Accent")
    
    // Semantic Colors
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)
    
    // Custom Colors
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
    static let info = Color.blue
    
    // Rating Colors
    static let ratingGold = Color(red: 255/255, green: 193/255, blue: 7/255)
}

// MARK: - View Extensions
extension View {
    /// Koşullu modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Card style
    func cardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 12) -> some View {
        self
            .padding(padding)
            .background(Color.backgroundSecondary)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Rounded button style
    func roundedButtonStyle(backgroundColor: Color = .brandPrimary, foregroundColor: Color = .white) -> some View {
        self
            .font(.headline)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .cornerRadius(12)
    }
    
    /// Loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
    }
    
    /// Error alert
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert("Hata", isPresented: .constant(error.wrappedValue != nil)) {
            Button("Tamam") {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
    
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - String Extensions
extension String {
    /// Email validation
    var isValidEmail: Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Password validation
    var isValidPassword: Bool {
        return self.count >= Constants.Validation.minPasswordLength &&
               self.count <= Constants.Validation.maxPasswordLength
    }
    
    /// Trim whitespace
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Phone number formatting
    var formattedPhoneNumber: String {
        let digits = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digits.count == 10 else { return self }
        
        let mask = "(XXX) XXX XX XX"
        var result = ""
        var index = digits.startIndex
        
        for char in mask where index < digits.endIndex {
            if char == "X" {
                result.append(digits[index])
                index = digits.index(after: index)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
}

// MARK: - Double Extensions
extension Double {
    /// Format as currency (Turkish Lira)
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = "₺"
        return formatter.string(from: NSNumber(value: self)) ?? "₺0.00"
    }
    
    /// Format as distance
    var asDistance: String {
        if self < 1 {
            return String(format: "%.0f m", self * 1000)
        }
        return String(format: "%.1f km", self)
    }
    
    /// Format as rating
    var asRating: String {
        String(format: "%.1f", self)
    }
}

// MARK: - Date Extensions
extension Date {
    /// Format as string
    func toString(format: String = "dd.MM.yyyy", locale: Locale = Locale(identifier: "tr_TR")) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    /// Relative time (2 saat önce, 3 gün önce)
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - Array Extensions
extension Array where Element == Review {
    /// Average rating
    var averageRating: Double {
        guard !isEmpty else { return 0 }
        let sum = self.reduce(0.0) { $0 + $1.rating }
        return sum / Double(count)
    }
}

// MARK: - Binding Extensions
extension Binding {
    /// Unwrap optional binding
    func unwrap<T>(defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

// MARK: - UIApplication Extensions
extension UIApplication {
    /// Get key window
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// Open settings
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        open(settingsURL)
    }
}

// MARK: - PreviewProvider Extension
#if DEBUG
extension PreviewProvider {
    /// Sample user for preview
    static var sampleUser: User {
        User(
            id: 1,
            email: "test@example.com",
            firstName: "Rabia",
            lastName: "Yolcu",
            phoneNumber: "+905551234567",
            profileImageUrl: nil,
            preferredLanguage: "tr",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    /// Sample restaurant for preview
    static var sampleRestaurant: Restaurant {
        Restaurant(
            id: 1,
            name: "Glutensiz Lezzetler",
            description: "Tamamen glutensiz menü sunan restoran",
            address: "Atatürk Caddesi No:123",
            city: "İstanbul",
            district: "Kadıköy",
            latitude: 40.9925,
            longitude: 29.0256,
            phoneNumber: "+902121234567",
            phone: "+902121234567",
            email: "info@glutensizlezzetler.com",
            website: "www.glutensizlezzetler.com",
            imageUrl: nil,
            image: nil,
            images: nil,
            cuisineTypes: ["Türk Mutfağı", "Dünya Mutfağı"],
            isChain: false,
            chainName: nil,
            averageRating: 4.5,
            rating: 4.5,
            reviewCount: 127,
            priceRange: .moderate,
            openingHours: nil,
            features: ["Glutensiz", "Vegan Seçenekler", "Açık Alan"],
            createdAt: Date(),
            updatedAt: Date(),
            distanceKm: 2.3
        )
    }
}
#endif
