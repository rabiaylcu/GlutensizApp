//
//  AuthViewModel.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Login form
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    
    // Register form
    @Published var registerFirstName = ""
    @Published var registerLastName = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerPasswordConfirm = ""
    
    // MARK: - Private Properties
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    init() {
        checkAuthStatus()
    }
    
    // MARK: - Auth Status
    
    /// Kullanıcının login durumunu kontrol et
    func checkAuthStatus() {
        // Token var mı kontrol et
        if let token = KeychainManager.shared.get(key: Constants.StorageKeys.accessToken),
           !token.isEmpty {
            isAuthenticated = true
            // TODO: Kullanıcı bilgilerini çek
            fetchUserProfile()
        }
    }
    
    // MARK: - Login
    
    /// Kullanıcı girişi
    func login() async {
        // Validation
        guard validateLoginForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(
                email: loginEmail.trimmed.lowercased(),
                password: loginPassword
            )
            
            print("🔐 Login request - Email: \(request.email)")
            
            let response: LoginResponse = try await networkManager.request(.login, body: request)
            
            print("✅ Login response received")
            print("✅ Token: \(response.accessToken.prefix(20))...")
            print("✅ User: \(response.user.firstName) \(response.user.lastName)")
            
            // Token'ı kaydet
            networkManager.setAccessToken(response.accessToken)
            
            // User bilgilerini kaydet
            currentUser = response.user
            isAuthenticated = true
            
            print("✅ Authentication successful! isAuthenticated = \(isAuthenticated)")
            
            // Form'u temizle
            clearLoginForm()
            
            isLoading = false
            
        } catch let error as NetworkError {
            print("❌ NetworkError: \(error.localizedDescription)")
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            print("❌ Unknown error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            isLoading = false
            errorMessage = "Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin."
            showError = true
        }
    }
    
    private func validateLoginForm() -> Bool {
        // Email kontrolü
        guard !loginEmail.trimmed.isEmpty else {
            errorMessage = "E-posta adresi boş bırakılamaz"
            showError = true
            return false
        }
        
        guard loginEmail.trimmed.isValidEmail else {
            errorMessage = "Geçerli bir e-posta adresi girin"
            showError = true
            return false
        }
        
        // Şifre kontrolü
        guard !loginPassword.isEmpty else {
            errorMessage = "Şifre boş bırakılamaz"
            showError = true
            return false
        }
        
        return true
    }
    
    // MARK: - Register
    
    /// Kullanıcı kaydı
    func register() async {
        // Validation
        guard validateRegisterForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(
                email: registerEmail.trimmed.lowercased(),
                password: registerPassword,
                passwordConfirm: registerPasswordConfirm,
                firstName: registerFirstName.trimmed,
                lastName: registerLastName.trimmed,
                phoneNumber: nil
            )
            
            print("📝 Register request - Email: \(request.email)")
            
            let response: RegisterResponse = try await networkManager.request(.register, body: request)
            
            print("✅ Register response received")
            print("✅ Message: \(response.message)")
            print("✅ User: \(response.user.firstName) \(response.user.lastName)")
            
            // Kayıt başarılı, şimdi otomatik login yap
            print("🔄 Auto-login başlatılıyor...")
            
            // Login bilgilerini geçici olarak sakla
            let email = registerEmail.trimmed.lowercased()
            let password = registerPassword
            
            // Register form'unu temizle
            clearRegisterForm()
            
            // Login bilgilerini set et
            loginEmail = email
            loginPassword = password
            
            // Otomatik login yap
            await login()
            
        } catch let error as NetworkError {
            print("❌ NetworkError: \(error.localizedDescription)")
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            print("❌ Unknown error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            isLoading = false
            errorMessage = "Kayıt olurken bir hata oluştu. Lütfen tekrar deneyin."
            showError = true
        }
    }
    
    private func validateRegisterForm() -> Bool {
        // Ad kontrolü
        guard !registerFirstName.trimmed.isEmpty else {
            errorMessage = "Ad boş bırakılamaz"
            showError = true
            return false
        }
        
        guard registerFirstName.trimmed.count >= 2 else {
            errorMessage = "Ad en az 2 karakter olmalıdır"
            showError = true
            return false
        }
        
        // Soyad kontrolü
        guard !registerLastName.trimmed.isEmpty else {
            errorMessage = "Soyad boş bırakılamaz"
            showError = true
            return false
        }
        
        guard registerLastName.trimmed.count >= 2 else {
            errorMessage = "Soyad en az 2 karakter olmalıdır"
            showError = true
            return false
        }
        
        // Email kontrolü
        guard !registerEmail.trimmed.isEmpty else {
            errorMessage = "E-posta adresi boş bırakılamaz"
            showError = true
            return false
        }
        
        guard registerEmail.trimmed.isValidEmail else {
            errorMessage = "Geçerli bir e-posta adresi girin"
            showError = true
            return false
        }
        
        // Şifre kontrolü
        guard !registerPassword.isEmpty else {
            errorMessage = "Şifre boş bırakılamaz"
            showError = true
            return false
        }
        
        guard registerPassword.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır"
            showError = true
            return false
        }
        
        // Şifre onay kontrolü
        guard !registerPasswordConfirm.isEmpty else {
            errorMessage = "Şifre onayı boş bırakılamaz"
            showError = true
            return false
        }
        
        guard registerPassword == registerPasswordConfirm else {
            errorMessage = "Şifreler eşleşmiyor"
            showError = true
            return false
        }
        
        return true
    }
    
    // MARK: - Logout
    
    /// Kullanıcı çıkışı
    func logout() async {
        isLoading = true
        
        do {
            // Backend'e logout isteği gönder (opsiyonel)
            try? await networkManager.request(.logout)
            
            // Token'ları temizle
            networkManager.clearTokens()
            
            // User bilgilerini temizle
            currentUser = nil
            isAuthenticated = false
            
            // Form'ları temizle
            clearLoginForm()
            clearRegisterForm()
            
            isLoading = false
            
        } catch {
            // Hata olsa bile logout yap
            networkManager.clearTokens()
            currentUser = nil
            isAuthenticated = false
            isLoading = false
        }
    }
    
    // MARK: - Fetch User Profile
    
    private func fetchUserProfile() {
        Task {
            do {
                let user: User = try await networkManager.request(.profile)
                currentUser = user
            } catch {
                // Token geçersizse logout yap
                await logout()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
    }
    
    private func clearRegisterForm() {
        registerFirstName = ""
        registerLastName = ""
        registerEmail = ""
        registerPassword = ""
        registerPasswordConfirm = ""
    }
    
    // MARK: - Computed Properties
    
    var isLoginFormValid: Bool {
        !loginEmail.trimmed.isEmpty &&
        loginEmail.isValidEmail &&
        !loginPassword.isEmpty
    }
    
    var isRegisterFormValid: Bool {
        !registerFirstName.trimmed.isEmpty &&
        !registerLastName.trimmed.isEmpty &&
        !registerEmail.trimmed.isEmpty &&
        registerEmail.isValidEmail &&
        !registerPassword.isEmpty &&
        registerPassword.count >= 6 &&
        !registerPasswordConfirm.isEmpty &&
        registerPassword == registerPasswordConfirm
    }
}
