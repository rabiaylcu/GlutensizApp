//
//  Home.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import SwiftUI
import MapKit

// MARK: - Home View (Tab Bar Container)
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Ana Sayfa - Liste
            RestaurantListView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Anasayfa")
                }
                .tag(0)
            
            // Harita
            RestaurantMapView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "map.fill" : "map")
                    Text("Harita")
                }
                .tag(1)
            
            // Favoriler
            FavoritesPlaceholder()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "heart.fill" : "heart")
                    Text("Favoriler")
                }
                .tag(2)
            
            // Profil
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profil")
                }
                .tag(3)
        }
        .accentColor(.green)
        .onAppear {
            Task {
                await viewModel.fetchRestaurants(refresh: true)
            }
        }
    }
}

// MARK: - Restaurant List View
struct RestaurantListView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText, placeholder: "Restoran veya mutfak ara...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Filtre Butonu
                            Button(action: {
                                showFilterSheet = true
                                HapticHelper.selection()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 14))
                                    Text("Filtrele")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.hasActiveFilters ? Color.green : Color.backgroundSecondary)
                                .foregroundColor(viewModel.hasActiveFilters ? .white : .textPrimary)
                                .cornerRadius(20)
                            }
                            
                            // Puan
                            FilterChip(title: "Puan", isSelected: viewModel.minRating != nil) {
                                // TODO: Puan filtresi
                            }
                            
                            // Mutfak
                            FilterChip(title: "Mutfak", isSelected: viewModel.selectedCuisineType != nil) {
                                // TODO: Mutfak filtresi
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    
                    // Restaurant List
                    if viewModel.isLoading && viewModel.restaurants.isEmpty {
                        LoadingView()
                    } else if viewModel.restaurants.isEmpty {
                        EmptyStateView(
                            icon: "fork.knife.circle",
                            title: "Restoran Bulunamadı",
                            message: "Aradığınız kriterlere uygun restoran bulunamadı. Filtreleri değiştirmeyi deneyin."
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredRestaurants) { restaurant in
                                    NavigationLink(destination: RestaurantDetailPlaceholder()) {
                                        RestaurantCard(restaurant: restaurant)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Load More
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .refreshable {
                            await viewModel.fetchRestaurants(refresh: true)
                        }
                    }
                }
            }
            .navigationTitle("Hoş Geldiniz")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilterSheet) {
                FilterView()
                    .environmentObject(viewModel)
            }
            .alert("Hata", isPresented: $viewModel.showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Restaurant Map View
struct RestaurantMapView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedRestaurant: Restaurant?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: viewModel.restaurants) { restaurant in
                    MapAnnotation(coordinate: restaurant.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
                        Button(action: {
                            selectedRestaurant = restaurant
                            HapticHelper.selection()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(selectedRestaurant?.id == restaurant.id ? .green : .red)
                                
                                if selectedRestaurant?.id == restaurant.id {
                                    Text("Seçili")
                                        .font(.system(size: 10, weight: .semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Search Bar Overlay
                VStack {
                    HStack(spacing: 12) {
                        SearchBar(text: $viewModel.searchText)
                            .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            // TODO: Filter
                            HapticHelper.selection()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(Color.backgroundPrimary)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Selected Restaurant Card
                    if let restaurant = selectedRestaurant {
                        VStack(spacing: 0) {
                            // Handle
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 36, height: 4)
                                .padding(.top, 8)
                            
                            // Restaurant Info
                            HStack(spacing: 12) {
                                // Image
                                if let imageUrl = restaurant.displayImage {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(12)
                                }
                                
                                // Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(restaurant.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.yellow)
                                        Text(restaurant.displayRating)
                                            .font(.system(size: 14, weight: .medium))
                                        Text("• \(restaurant.cuisineTypesString)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Text(restaurant.address)
                                        .font(.system(size: 12))
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // TODO: Favorite
                                }) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(16)
                            
                            // Action Buttons
                            HStack(spacing: 12) {
                                NavigationLink(destination: RestaurantDetailPlaceholder()) {
                                    Text("Detayları Gör")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    // TODO: Directions
                                    HapticHelper.impact()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                        Text("Rota")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(Color.backgroundPrimary)
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                        .shadow(radius: 8)
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if let location = viewModel.userLocation {
                region.center = location.coordinate
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green.opacity(0.2) : Color.backgroundSecondary)
                .foregroundColor(isSelected ? .green : .textPrimary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1)
                )
        }
    }
}

// MARK: - Filter View (Placeholder)
struct FilterView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Mesafe") {
                    HStack {
                        Text("Max: \(Int(viewModel.maxDistance ?? 10)) km")
                        Spacer()
                        Slider(value: Binding(
                            get: { viewModel.maxDistance ?? 10 },
                            set: { viewModel.maxDistance = $0 }
                        ), in: 1...50, step: 1)
                    }
                }
                
                Section("Puan") {
                    Picker("Minimum Puan", selection: Binding(
                        get: { viewModel.minRating ?? 0 },
                        set: { viewModel.minRating = $0 == 0 ? nil : $0 }
                    )) {
                        Text("Hepsi").tag(0.0)
                        Text("4.0+").tag(4.0)
                        Text("4.5+").tag(4.5)
                    }
                }
                
                Section {
                    Button("Filtreleri Uygula") {
                        Task {
                            await viewModel.applyFilters()
                            dismiss()
                        }
                    }
                    
                    Button("Filtreleri Temizle") {
                        Task {
                            await viewModel.clearFilters()
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtrele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                if let user = authViewModel.currentUser {
                    Section {
                        HStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user.initials)
                                        .font(.title2)
                                        .foregroundColor(.green)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Hesap") {
                    NavigationLink(destination: Text("Profili Düzenle")) {
                        Label("Profili Düzenle", systemImage: "person.circle")
                    }
                    
                    NavigationLink(destination: Text("Ayarlar")) {
                        Label("Ayarlar", systemImage: "gearshape")
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await authViewModel.logout()
                        }
                    }) {
                        Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profil")
        }
    }
}

// MARK: - Custom Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
#endif
