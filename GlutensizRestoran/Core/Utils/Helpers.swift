//
//  Helpers.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import SwiftUI

// MARK: - Validation Helper
struct ValidationHelper {
    
    /// Email formatını kontrol et
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Şifre kurallarını kontrol et
    static func isValidPassword(_ password: String) -> (isValid: Bool, message: String?) {
        guard password.count >= Constants.Validation.minPasswordLength else {
            return (false, "Şifre en az \(Constants.Validation.minPasswordLength) karakter olmalıdır")
        }
        
        guard password.count <= Constants.Validation.maxPasswordLength else {
            return (false, "Şifre en fazla \(Constants.Validation.maxPasswordLength) karakter olmalıdır")
        }
        
        // En az bir büyük harf
        let uppercaseRegex = ".*[A-Z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) {
            return (false, "Şifre en az bir büyük harf içermelidir")
        }
        
        // En az bir küçük harf
        let lowercaseRegex = ".*[a-z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) {
            return (false, "Şifre en az bir küçük harf içermelidir")
        }
        
        // En az bir rakam
        let digitRegex = ".*[0-9]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
            return (false, "Şifre en az bir rakam içermelidir")
        }
        
        return (true, nil)
    }
    
    /// Telefon numarası formatını kontrol et (Türkiye)
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        // Sadece rakamları al
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Türkiye telefon numarası: 10 veya 11 haneli (5XXXXXXXXX veya 905XXXXXXXXX)
        if digits.count == 10 {
            return digits.hasPrefix("5")
        } else if digits.count == 11 {
            return digits.hasPrefix("90") && digits[digits.index(digits.startIndex, offsetBy: 2)] == "5"
        }
        
        return false
    }
    
    /// İsim formatını kontrol et
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2
    }
}

// MARK: - Format Helper
struct FormatHelper {
    
    /// Telefon numarasını formatla
    static func formatPhoneNumber(_ phone: String) -> String {
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard digits.count == 10 else { return phone }
        
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
    
    /// Para formatı
    static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = "₺"
        return formatter.string(from: NSNumber(value: amount)) ?? "₺0.00"
    }
    
    /// Mesafe formatı
    static func formatDistance(_ distanceInKm: Double) -> String {
        if distanceInKm < 1 {
            return String(format: "%.0f m", distanceInKm * 1000)
        }
        return String(format: "%.1f km", distanceInKm)
    }
    
    /// Tarih formatı
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    /// Saat formatı
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Alert Helper
struct AlertHelper {
    
    static func showError(title: String = "Hata", message: String) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("Tamam"))
        )
    }
    
    static func showSuccess(title: String = "Başarılı", message: String, action: (() -> Void)? = nil) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("Tamam")) {
                action?()
            }
        )
    }
    
    static func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Evet",
        cancelTitle: String = "İptal",
        confirmAction: @escaping () -> Void
    ) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .destructive(Text(confirmTitle)) {
                confirmAction()
            },
            secondaryButton: .cancel(Text(cancelTitle))
        )
    }
}

// MARK: - UserDefaults Helper
struct UserDefaultsHelper {
    
    private static let defaults = UserDefaults.standard
    
    // MARK: - Save
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    static func saveString(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    static func saveBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    static func saveInt(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Get
    static func get<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    static func getString(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    static func getBool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    static func getInt(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    // MARK: - Remove
    static func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    // MARK: - Clear All
    static func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
    }
}

// MARK: - Haptic Feedback Helper
struct HapticHelper {
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
