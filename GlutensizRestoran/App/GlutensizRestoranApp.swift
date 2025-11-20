//
//
//  GlutensizRestoranApp.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import SwiftUI

@main
struct GlutensizRestoranApp: App {
    
    // MARK: - State Objects
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var authViewModel = AuthViewModel()
    
    // MARK: - App Initialization
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    // Ana uygulama
                    HomeView()
                        .environmentObject(locationManager)
                        .environmentObject(authViewModel)
                } else {
                    // Authentication ekranı
                    LoginView()
                        .environmentObject(locationManager)
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Konum izni iste
                locationManager.requestLocationPermission()
            }
        }
    }
    
    // MARK: - Setup
    private func setupApp() {
        // UI Appearance ayarları
        setupAppearance()
        
        // Network monitoring
        setupNetworkMonitoring()
    }
    
    private func setupAppearance() {
        // Navigation Bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Tab Bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    private func setupNetworkMonitoring() {
        // Network reachability monitoring eklenebilir
        // Gelecekte internet bağlantısı kontrolü için
    }
}
