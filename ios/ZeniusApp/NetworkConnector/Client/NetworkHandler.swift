//
//  NetworkHandler.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public protocol NetworkHandlerProtocol {
    func executeQuery<T: Decodable>(
        operationName: String,
        query: String,
        variables: [String: Any]?
    ) async -> NetworkResult<T>

    func executeMutation<T: Decodable>(
        operationName: String,
        mutation: String,
        variables: [String: Any]?
    ) async -> NetworkResult<T>

    func setAuthToken(_ token: String?)
}

public final class NetworkHandler: NetworkHandlerProtocol {
    private let config: NetworkEnvironmentConfig
    private let session: URLSession
    private let logger: NetworkLogger
    private var authToken: String?

    public init(config: NetworkEnvironmentConfig, session: URLSession? = nil) {
        self.config = config
        self.logger = NetworkLogger(isLoggingEnabled: config.enableLogging)

        if let providedSession = session {
            self.session = providedSession
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = config.requestTimeout
            sessionConfig.timeoutIntervalForResource = config.requestTimeout * 2

            let pinningDelegate = SSLPinningDelegate(
                primaryPin: config.primarySSLPin,
                backupPin: config.backupSSLPin
            )

            self.session = URLSession(
                configuration: sessionConfig,
                delegate: pinningDelegate,
                delegateQueue: nil
            )
        }
    }

    public func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    public func executeQuery<T: Decodable>(
        operationName: String,
        query: String,
        variables: [String: Any]? = nil
    ) async -> NetworkResult<T> {
        await request(
            operationType: .query,
            operationName: operationName,
            document: query,
            variables: variables
        )
    }

    public func executeMutation<T: Decodable>(
        operationName: String,
        mutation: String,
        variables: [String: Any]? = nil
    ) async -> NetworkResult<T> {
        // Mutations do NOT retry automatically to prevent non-idempotent duplicate operations
        await request(
            operationType: .mutation,
            operationName: operationName,
            document: mutation,
            variables: variables
        )
    }

    private func request<T: Decodable>(
        operationType: GraphQLOperationType,
        operationName: String,
        document: String,
        variables: [String: Any]?
    ) async -> NetworkResult<T> {
        var urlRequest = URLRequest(url: config.graphQLEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("iOS", forHTTPHeaderField: "X-Platform")

        if let token = authToken, !token.isEmpty {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let graphqlBody = GraphQLRequest(
            operationName: operationName,
            query: document,
            variables: variables
        )

        do {
            urlRequest.httpBody = try JSONEncoder().encode(graphqlBody)
        } catch {
            return .transportError(.serializationError(error.localizedDescription))
        }

        logger.logRequest(urlRequest, operationName: operationName)
        let startTime = Date()

        do {
            let (data, response) = try await session.data(for: urlRequest)
            let duration = Date().timeIntervalSince(startTime)
            let httpResponse = response as? HTTPURLResponse
            logger.logResponse(httpResponse, data: data, duration: duration, operationName: operationName)

            if let statusCode = httpResponse?.statusCode, (statusCode < 200 || statusCode >= 300) {
                if statusCode == 401 {
                    return .graphQLErrors([GraphQLErrorItem(message: "Unauthorized", code: "UNAUTHENTICATED")])
                }
                if statusCode == 403 {
                    return .graphQLErrors([GraphQLErrorItem(message: "Forbidden", code: "FORBIDDEN")])
                }
                return .transportError(.invalidResponse(statusCode: statusCode))
            }

            let decoder = JSONDecoder()
            let graphqlResponse = try decoder.decode(GraphQLResponse<T>.self, from: data)

            if let errors = graphqlResponse.errors, !errors.isEmpty {
                return .graphQLErrors(errors)
            }

            if let responseData = graphqlResponse.data {
                return .success(responseData)
            }

            return .transportError(.serializationError("Respons data bernilai null tanpa error."))

        } catch let urlError as URLError {
            let duration = Date().timeIntervalSince(startTime)
            logger.logResponse(nil, data: nil, duration: duration, operationName: operationName)

            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .transportError(.noInternet)
            case .timedOut:
                return .transportError(.timeout)
            case .serverCertificateUntrusted, .clientCertificateRejected, .secureConnectionFailed:
                return .transportError(.sslPinningFailure)
            default:
                return .transportError(.unknownNetworkError(urlError.localizedDescription))
            }
        } catch {
            return .transportError(.unknownNetworkError(error.localizedDescription))
        }
    }
}
