//
//  EnvironmentConfig.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public enum AppEnvironment: String, CaseIterable {
    case sit = "SIT"
    case uat = "UAT"
    case production = "Production"
}

public struct NetworkEnvironmentConfig {
    public let environment: AppEnvironment
    public let graphQLEndpoint: URL
    public let primarySSLPin: String
    public let backupSSLPin: String
    public let connectionTimeout: TimeInterval
    public let requestTimeout: TimeInterval
    public let enableLogging: Bool

    public init(
        environment: AppEnvironment,
        graphQLEndpoint: URL,
        primarySSLPin: String,
        backupSSLPin: String,
        connectionTimeout: TimeInterval = 15.0,
        requestTimeout: TimeInterval = 30.0,
        enableLogging: Bool = true
    ) {
        self.environment = environment
        self.graphQLEndpoint = graphQLEndpoint
        self.primarySSLPin = primarySSLPin
        self.backupSSLPin = backupSSLPin
        self.connectionTimeout = connectionTimeout
        self.requestTimeout = requestTimeout
        self.enableLogging = enableLogging
    }

    // MARK: - Main Zenius Backend API Configuration
    public static func config(for environment: AppEnvironment) -> NetworkEnvironmentConfig {
        switch environment {
        case .sit:
            return NetworkEnvironmentConfig(
                environment: .sit,
                graphQLEndpoint: URL(string: "https://sit-api.zenius.net/graphql")!,
                primarySSLPin: "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                backupSSLPin: "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=",
                enableLogging: true
            )
        case .uat:
            return NetworkEnvironmentConfig(
                environment: .uat,
                graphQLEndpoint: URL(string: "https://uat-api.zenius.net/graphql")!,
                primarySSLPin: "sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=",
                backupSSLPin: "sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=",
                enableLogging: true
            )
        case .production:
            return NetworkEnvironmentConfig(
                environment: .production,
                graphQLEndpoint: URL(string: "https://api.zenius.net/graphql")!,
                primarySSLPin: "sha256/EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=",
                backupSSLPin: "sha256/FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF=",
                enableLogging: false
            )
        }
    }

    // MARK: - Pokemon Public GraphQL API Configuration (Dipakai untuk Icon Widget)
    public static func pokemonConfig(for environment: AppEnvironment = .production) -> NetworkEnvironmentConfig {
        return NetworkEnvironmentConfig(
            environment: environment,
            graphQLEndpoint: URL(string: "https://graphql-pokeapi.graphcdn.app")!,
            primarySSLPin: "sha256/ITZbGR1b9QSxHaCyIzQwPxw/zcps5yJ/3f1L6cF+xA8=",
            backupSSLPin: "sha256/mE3uq78nni+69xViJGVDAMfGy4zKZReZ6kOAqT3pM8s=",
            enableLogging: environment != .production
        )
    }
}
