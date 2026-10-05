//
//  NetworkLogger.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public final class NetworkLogger {
    private let isLoggingEnabled: Bool

    public init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }

    public func logRequest(_ request: URLRequest, operationName: String) {
        guard isLoggingEnabled else { return }

        let urlString = request.url?.absoluteString ?? "N/A"
        let method = request.httpMethod ?? "POST"

        print("────────────── [GRAPHQL REQUEST] ──────────────")
        print("▶ Operation: \(operationName)")
        print("▶ URL: \(urlString)")
        print("▶ Method: \(method)")

        if let headers = request.allHTTPHeaderFields {
            print("▶ Headers:")
            for (key, value) in headers {
                if key.lowercased() == "authorization" || key.lowercased().contains("token") || key.lowercased().contains("secret") {
                    print("   - \(key): [REDACTED]")
                } else {
                    print("   - \(key): \(value)")
                }
            }
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("▶ Body: \(sanitizePayload(bodyString))")
        }
        print("───────────────────────────────────────────────")
    }

    public func logResponse(_ response: HTTPURLResponse?, data: Data?, duration: TimeInterval, operationName: String) {
        guard isLoggingEnabled else { return }

        let statusCode = response?.statusCode ?? 0
        let statusString = statusCode > 0 ? "\(statusCode)" : "FAILED"

        print("────────────── [GRAPHQL RESPONSE] ──────────────")
        print("◀ Operation: \(operationName)")
        print("◀ Status: \(statusString)")
        print("◀ Duration: \(String(format: "%.2f", duration * 1000)) ms")

        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
            print("◀ Payload: \(sanitizePayload(responseString))")
        }
        print("────────────────────────────────────────────────")
    }

    private func sanitizePayload(_ payload: String) -> String {
        // Redact any tokens or passwords in payload string
        var sanitized = payload
        let sensitiveKeys = ["token", "accessToken", "refreshToken", "password", "secret"]

        for key in sensitiveKeys {
            let pattern = "\"\(key)\"\\s*:\\s*\"[^\"]+\""
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(location: 0, length: sanitized.utf16.count)
                sanitized = regex.stringByReplacingMatches(in: sanitized, options: [], range: range, withTemplate: "\"\(key)\": \"[REDACTED]\"")
            }
        }
        return sanitized
    }
}
