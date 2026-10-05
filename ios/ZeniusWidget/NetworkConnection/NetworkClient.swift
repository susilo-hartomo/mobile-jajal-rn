import Foundation

struct NetworkClient {
  public static let shared = NetworkClient()

  private let baseURL: URL
  private let session: URLSession
  private let decoder: JSONDecoder

  init(
    requestTimeout: TimeInterval = 8,
    resourceTimeout: TimeInterval = 10,
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.baseURL = WidgetNetworkEnvironment.apiURL
    self.decoder = decoder

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = requestTimeout
    configuration.timeoutIntervalForResource = resourceTimeout

    self.session = URLSession(
      configuration: configuration
    )
  }

  func request<Response: Decodable>(
    _ endpoint: Endpoint,
    responseType: Response.Type = Response.self
  ) async throws -> Response {

    let url = endpoint.path.isEmpty
      ? baseURL
      : baseURL.appendingPathComponent(endpoint.path)
    var request = URLRequest(url: url)

    request.httpMethod = endpoint.method.rawValue
    request.httpBody = endpoint.body
    endpoint.headers.forEach { key, value in
      request.setValue(
        value,
        forHTTPHeaderField: key
      )
    }

    do {
      let (data, response) = try await session.data(
        for: request
      )

      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
      }

      guard 200..<300 ~= httpResponse.statusCode else {
        throw NetworkError.httpError(
          statusCode: httpResponse.statusCode,
          data: data
        )
      }

      do {
        return try decoder.decode(
          Response.self,
          from: data
        )
      } catch {
        throw NetworkError.decodingError(error)
      }
    } catch let error as NetworkError {
      throw error
    } catch {
      throw NetworkError.transportError(error)
    }
  }
}
 