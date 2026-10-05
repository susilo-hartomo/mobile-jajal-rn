//
//  NetworkHandlerTests.swift
//  ZeniusApp / NetworkConnector
//

import Foundation

public final class MockURLProtocol: URLProtocol {
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override public func stopLoading() {}
}

public final class NetworkHandlerTests {
    public static func runAllTests() async {
        print("🧪 [NETWORK TEST] Running Network Handler Test Suite...")

        testEnvironmentConfiguration()
        await testGraphQLQuerySuccess()
        await testGraphQLErrorHandling()
        await testNetworkTimeoutError()
        await testGraphQLMutationSuccess()

        print("✅ [NETWORK TEST] All Network Handler Tests Passed!")
    }

    private static func testEnvironmentConfiguration() {
        let sitConfig = NetworkEnvironmentConfig.config(for: .sit)
        assert(sitConfig.graphQLEndpoint.absoluteString == "https://sit-api.zenius.net/graphql")
        assert(sitConfig.enableLogging == true)

        let uatConfig = NetworkEnvironmentConfig.config(for: .uat)
        assert(uatConfig.graphQLEndpoint.absoluteString == "https://uat-api.zenius.net/graphql")

        let prodConfig = NetworkEnvironmentConfig.config(for: .production)
        assert(prodConfig.graphQLEndpoint.absoluteString == "https://api.zenius.net/graphql")
        assert(prodConfig.enableLogging == false)

        print("  ✓ Environment Configuration Test Passed")
    }

    private static func createMockSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: sessionConfig)
    }

    private static func testGraphQLQuerySuccess() async {
        let session = createMockSession()
        let config = NetworkEnvironmentConfig.config(for: .sit)
        let handler = NetworkHandler(config: config, session: session)
        let dataSource = WidgetNetworkDataSource(networkHandler: handler)

        MockURLProtocol.requestHandler = { request in
            let jsonString = """
            {
              "data": {
                "widgetData": {
                  "id": "w123",
                  "activeSubject": "Fisika",
                  "streakDays": 10,
                  "dailyProgress": 0.8,
                  "minutesLearned": 60
                }
              }
            }
            """
            let data = jsonString.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let result = await dataSource.fetchWidgetData(userId: "user-1")
        assert(result.isSuccess)
        assert(result.data?.activeSubject == "Fisika")
        assert(result.data?.streakDays == 10)
        print("  ✓ GraphQL Query Success Test Passed")
    }

    private static func testGraphQLErrorHandling() async {
        let session = createMockSession()
        let config = NetworkEnvironmentConfig.config(for: .sit)
        let handler = NetworkHandler(config: config, session: session)
        let dataSource = WidgetNetworkDataSource(networkHandler: handler)

        MockURLProtocol.requestHandler = { request in
            let jsonString = """
            {
              "data": null,
              "errors": [
                {
                  "message": "Unauthorized access",
                  "code": "UNAUTHENTICATED"
                }
              ]
            }
            """
            let data = jsonString.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let result = await dataSource.fetchWidgetData(userId: "user-1")
        assert(!result.isSuccess)
        assert(result.graphqlErrors?.first?.category == .authentication)
        print("  ✓ GraphQL Error Handling Test Passed")
    }

    private static func testNetworkTimeoutError() async {
        let session = createMockSession()
        let config = NetworkEnvironmentConfig.config(for: .sit)
        let handler = NetworkHandler(config: config, session: session)
        let dataSource = WidgetNetworkDataSource(networkHandler: handler)

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        let result = await dataSource.fetchWidgetData(userId: "user-1")
        assert(!result.isSuccess)
        assert(result.error == .timeout)
        print("  ✓ Network Timeout Error Test Passed")
    }

    private static func testGraphQLMutationSuccess() async {
        let session = createMockSession()
        let config = NetworkEnvironmentConfig.config(for: .sit)
        let handler = NetworkHandler(config: config, session: session)
        let dataSource = WidgetNetworkDataSource(networkHandler: handler)

        MockURLProtocol.requestHandler = { request in
            let jsonString = """
            {
              "data": {
                "updateWidgetAction": {
                  "success": true,
                  "message": "Widget updated"
                }
              }
            }
            """
            let data = jsonString.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let result = await dataSource.updateWidgetAction(actionId: "act-1", enabled: true)
        assert(result.isSuccess)
        assert(result.data?.success == true)
        print("  ✓ GraphQL Mutation Success Test Passed")
    }
}
