//
//  HomeViewModel.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Search & Filter
    @Published var searchText = ""
    @Published var selectedCity: String?
    @Published var selectedCuisineType: String?
    @Published var minRating: Double?
    @Published var maxDistance: Double?
    
    // View Mode
    @Published var showMapView = false
    
    // Location
    @Published var userLocation: CLLocation?
    
    // MARK: - Private Properties
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Pagination
    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMore = true
    
    // MARK: - Initialization
    init() {
        setupLocationObserver()
    }
    
    // MARK: - Location Observer
    private func setupLocationObserver() {
        locationManager.$location
            .sink { [weak self] location in
                self?.userLocation = location
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Restaurants
    func fetchRestaurants(refresh: Bool = false) async {
        if refresh {
            currentPage = 0
            canLoadMore = true
            restaurants = []
        }
        
        guard canLoadMore else { return }
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var filters = RestaurantFilters()
            filters.city = selectedCity
            filters.cuisineType = selectedCuisineType
            filters.minRating = minRating
            filters.maxDistance = maxDistance
            
            // Build URL with query parameters
            var endpoint: APIEndpoint = .restaurants(filters: filters)
            
            let response: RestaurantsResponse = try await networkManager.request(endpoint)
            
            if refresh {
                restaurants = response.restaurants
            } else {
                restaurants.append(contentsOf: response.restaurants)
            }
            
            // Check if we can load more
            canLoadMore = response.restaurants.count == pageSize
            currentPage += 1
            
            isLoading = false
            
        } catch let error as NetworkError {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Fetch restaurants error: \(error.localizedDescription)")
        } catch {
            isLoading = false
            errorMessage = "Restoranlar yüklenirken bir hata oluştu"
            showError = true
            print("❌ Unknown error: \(error)")
        }
    }
    
    // MARK: - Search
    func searchRestaurants() async {
        guard !searchText.trimmed.isEmpty else {
            await fetchRestaurants(refresh: true)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: RestaurantsResponse = try await networkManager.request(
                .searchRestaurants(query: searchText.trimmed)
            )
            
            restaurants = response.restaurants
            isLoading = false
            
        } catch let error as NetworkError {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            isLoading = false
            errorMessage = "Arama sırasında bir hata oluştu"
            showError = true
        }
    }
    
    // MARK: - Nearby Restaurants
    func fetchNearbyRestaurants() async {
        guard let location = userLocation else {
            errorMessage = "Konum bilgisi alınamadı"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: RestaurantsResponse = try await networkManager.request(
                .nearbyRestaurants(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    radius: maxDistance ?? 10.0
                )
            )
            
            restaurants = response.restaurants
            isLoading = false
            
        } catch let error as NetworkError {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            isLoading = false
            errorMessage = "Yakındaki restoranlar yüklenirken hata oluştu"
            showError = true
        }
    }
    
    // MARK: - Filter & Sort
    func applyFilters() async {
        await fetchRestaurants(refresh: true)
    }
    
    func clearFilters() async {
        selectedCity = nil
        selectedCuisineType = nil
        minRating = nil
        maxDistance = nil
        await fetchRestaurants(refresh: true)
    }
    
    // MARK: - Helper Methods
    func toggleViewMode() {
        showMapView.toggle()
        HapticHelper.selection()
    }
    
    // MARK: - Computed Properties
    var hasActiveFilters: Bool {
        selectedCity != nil ||
        selectedCuisineType != nil ||
        minRating != nil ||
        maxDistance != nil
    }
    
    var filteredRestaurants: [Restaurant] {
        guard !searchText.trimmed.isEmpty else { return restaurants }
        
        return restaurants.filter { restaurant in
            restaurant.name.lowercased().contains(searchText.trimmed.lowercased()) ||
            restaurant.cuisineTypesString.lowercased().contains(searchText.trimmed.lowercased())
        }
    }
}
