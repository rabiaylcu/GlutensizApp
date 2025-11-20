//
//  NetworkError.swift
//  GlutensizRestoran
//
//  Created by Rabia Yolcu on 2025
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case encodingError
    case serverError(statusCode: Int)
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case noInternetConnection
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Sunucudan veri alınamadı"
        case .decodingError:
            return "Veri işlenirken hata oluştu"
        case .encodingError:
            return "Veri gönderilirken hata oluştu"
        case .serverError(let statusCode):
            return "Sunucu hatası: \(statusCode)"
        case .unauthorized:
            return "Oturum süreniz dolmuş. Lütfen tekrar giriş yapın"
        case .forbidden:
            return "Bu işlem için yetkiniz yok"
        case .notFound:
            return "İstenen kaynak bulunamadı"
        case .timeout:
            return "İstek zaman aşımına uğradı"
        case .noInternetConnection:
            return "İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin"
        case .unknown(let error):
            return "Beklenmeyen bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Lütfen tekrar giriş yapın"
        case .noInternetConnection:
            return "İnternet bağlantınızı kontrol edin ve tekrar deneyin"
        case .timeout:
            return "Lütfen tekrar deneyin"
        case .serverError:
            return "Lütfen daha sonra tekrar deneyin"
        default:
            return nil
        }
    }
}
