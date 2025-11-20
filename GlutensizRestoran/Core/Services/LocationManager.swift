//
//  LocationManager.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    // Published properties
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var locationError: LocationError?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // 100 metre değişiklikte güncelle
        
        authorizationStatus = locationManager.authorizationStatus
        updateLocationEnabledStatus()
    }
    
    // MARK: - Public Methods
    
    /// Konum izni iste
    func requestLocationPermission() {
        // Main thread'de güvenli çağrı
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch self.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                self.locationError = .permissionDenied
            @unknown default:
                break
            }
        }
    }
    
    /// Konum güncellemelerini başlat
    func startUpdatingLocation() {
        guard isLocationEnabled else {
            locationError = .locationServicesDisabled
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    /// Konum güncellemelerini durdur
    func stopUpdatingLocation() {
        DispatchQueue.main.async { [weak self] in
            self?.locationManager.stopUpdatingLocation()
        }
    }
    
    /// Tek seferlik konum al
    func requestLocation() {
        guard isLocationEnabled else {
            locationError = .locationServicesDisabled
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.locationManager.requestLocation()
        }
    }
    
    /// İki konum arasındaki mesafeyi hesapla (km)
    func distance(from: CLLocation, to: CLLocation) -> Double {
        let distanceInMeters = from.distance(from: to)
        return distanceInMeters / 1000 // km'ye çevir
    }
    
    /// Koordinatlardan CLLocation oluştur
    func makeLocation(latitude: Double, longitude: Double) -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Private Methods
    
    private func updateLocationEnabledStatus() {
        isLocationEnabled = CLLocationManager.locationServicesEnabled()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        updateLocationEnabledStatus()
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            startUpdatingLocation()
        case .denied, .restricted:
            locationError = .permissionDenied
            stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Konum doğruluğunu kontrol et
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // Eski konumları filtrele (5 saniyeden eski)
        let age = -newLocation.timestamp.timeIntervalSinceNow
        if age > 5 {
            return
        }
        
        location = newLocation
        locationError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .locationUnknown
            case .network:
                locationError = .networkError
            default:
                locationError = .unknown(error.localizedDescription)
            }
        } else {
            locationError = .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Location Error
enum LocationError: LocalizedError {
    case permissionDenied
    case locationServicesDisabled
    case locationUnknown
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Konum izni reddedildi. Lütfen ayarlardan konum iznini açın."
        case .locationServicesDisabled:
            return "Konum servisleri kapalı. Lütfen ayarlardan konum servislerini açın."
        case .locationUnknown:
            return "Konumunuz belirlenemedi. Lütfen tekrar deneyin."
        case .networkError:
            return "Ağ hatası. Lütfen internet bağlantınızı kontrol edin."
        case .unknown(let message):
            return "Konum hatası: \(message)"
        }
    }
}

// MARK: - Extension for coordinates
extension CLLocation {
    var coordinateString: String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}
