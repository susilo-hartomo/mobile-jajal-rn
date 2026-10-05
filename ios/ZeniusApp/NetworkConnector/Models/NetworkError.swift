//
//  NetworkError.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public enum NetworkError: Error, Equatable {
    case noInternet
    case timeout
    case sslPinningFailure
    case tlsFailure
    case invalidResponse(statusCode: Int)
    case serializationError(String)
    case unknownNetworkError(String)

    public var localizedDescription: String {
        switch self {
        case .noInternet:
            return "Tidak ada koneksi internet."
        case .timeout:
            return "Waktu koneksi habis (Timeout)."
        case .sslPinningFailure:
            return "Koneksi ditolak: Gagal validasi Sertifikat SSL (SSL Pinning Failure)."
        case .tlsFailure:
            return "Gagal melakukan handshake TLS/SSL."
        case .invalidResponse(let statusCode):
            return "Respons server tidak valid (HTTP Status \(statusCode))."
        case .serializationError(let details):
            return "Gagal memproses data respons: \(details)"
        case .unknownNetworkError(let message):
            return "Kesalahan jaringan: \(message)"
        }
    }
}

public enum GraphQLErrorCategory: String, Codable {
    case authentication = "UNAUTHENTICATED"
    case authorization = "FORBIDDEN"
    case validation = "BAD_USER_INPUT"
    case businessError = "BUSINESS_ERROR"
    case unknown = "UNKNOWN"
}

public struct GraphQLErrorItem: Codable, Equatable {
    public let message: String
    public let code: String?
    public let path: [String]?

    public init(message: String, code: String? = nil, path: [String]? = nil) {
        self.message = message
        self.code = code
        self.path = path
    }

    public var category: GraphQLErrorCategory {
        guard let code = code else {
            if message.lowercased().contains("unauthorized") || message.lowercased().contains("unauthenticated") {
                return .authentication
            }
            if message.lowercased().contains("forbidden") || message.lowercased().contains("access denied") {
                return .authorization
            }
            return .unknown
        }
        switch code.uppercased() {
        case "UNAUTHENTICATED", "UNAUTHORIZED":
            return .authentication
        case "FORBIDDEN", "ACCESS_DENIED":
            return .authorization
        case "BAD_USER_INPUT", "VALIDATION_ERROR":
            return .validation
        case "BUSINESS_ERROR":
            return .businessError
        default:
            return .unknown
        }
    }
}
