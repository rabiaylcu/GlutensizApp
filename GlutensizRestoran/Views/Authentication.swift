//
//  Authentication.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Hoş Geldiniz")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.textPrimary)
                            
                            Text("Giriş yapmak için bilgilerinizi girin")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                TextField("ornek@mail.com", text: $viewModel.loginEmail)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    if isPasswordVisible {
                                        TextField("********", text: $viewModel.loginPassword)
                                            .textContentType(.password)
                                    } else {
                                        SecureField("********", text: $viewModel.loginPassword)
                                            .textContentType(.password)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                        HapticHelper.selection()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.backgroundSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Şifrenizi mi unuttunuz?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.green)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Login Button
                        Button(action: {
                            HapticHelper.impact()
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Giriş Yap")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(viewModel.isLoginFormValid && !viewModel.isLoading ? Color.green : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Register Link
                        HStack(spacing: 4) {
                            Text("Hesabınız yok mu?")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                            
                            NavigationLink(destination: RegisterView()) {
                                Text("Kayıt Ol")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.green)
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Hata", isPresented: $viewModel.showError) {
                Button("Tamam", role: .cancel) {
                    viewModel.showError = false
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Hesap Oluştur")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Boş space (dengeli görünüm için)
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Form Fields
                        VStack(spacing: 16) {
                            // Ad Soyad
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ad Soyad")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                HStack(spacing: 12) {
                                    TextField("Ad", text: $viewModel.registerFirstName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .textContentType(.givenName)
                                        .autocorrectionDisabled()
                                    
                                    TextField("Soyad", text: $viewModel.registerLastName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .textContentType(.familyName)
                                        .autocorrectionDisabled()
                                }
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta Adresi")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                TextField("e-posta@adresiniz.com", text: $viewModel.registerEmail)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            
                            // Şifre
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Şifrenizi oluşturun", text: $viewModel.registerPassword)
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Şifrenizi oluşturun", text: $viewModel.registerPassword)
                                            .textContentType(.newPassword)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                        HapticHelper.selection()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.backgroundSecondary)
                                .cornerRadius(12)
                            }
                            
                            // Şifre Onay
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre Onay")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    if isConfirmPasswordVisible {
                                        TextField("Şifrenizi tekrar girin", text: $viewModel.registerPasswordConfirm)
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Şifrenizi tekrar girin", text: $viewModel.registerPasswordConfirm)
                                            .textContentType(.newPassword)
                                    }
                                    
                                    Button(action: {
                                        isConfirmPasswordVisible.toggle()
                                        HapticHelper.selection()
                                    }) {
                                        Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.backgroundSecondary)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Terms Text
                        Text("Devam ederek ")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        +
                        Text("Kullanım Koşulları")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.green)
                        +
                        Text(" ve ")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        +
                        Text("Gizlilik Politikası")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.green)
                        +
                        Text("'nı kabul etmiş olursunuz.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Bottom Buttons
                VStack(spacing: 16) {
                    // Register Button
                    Button(action: {
                        HapticHelper.impact()
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Kayıt Ol")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.isRegisterFormValid && !viewModel.isLoading ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isRegisterFormValid || viewModel.isLoading)
                    
                    // Login Link
                    HStack(spacing: 4) {
                        Text("Zaten hesabın var mı?")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Giriş Yap")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.green)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
        .navigationBarHidden(true)
        .alert("Hata", isPresented: $viewModel.showError) {
            Button("Tamam", role: .cancel) {
                viewModel.showError = false
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Şifremi Unuttum")
                .font(.title)
                .padding()
            
            Text("Bu özellik yakında eklenecek")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Geri") {
                dismiss()
            }
            .roundedButtonStyle()
            .padding()
        }
        .navigationTitle("Şifremi Unuttum")
    }
}

// MARK: - Custom Text Field Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.backgroundSecondary)
            .cornerRadius(12)
    }
}

// MARK: - Preview
#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
#endif
