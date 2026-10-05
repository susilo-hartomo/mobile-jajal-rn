import Foundation

enum NetworkError: LocalizedError {
  case invalidURL
  case invalidResponse
  case httpError(statusCode: Int, data: Data?)
  case encodingError(Error)
  case decodingError(Error)
  case transportError(Error)

  var errorDescription: String? {
    switch self {
      case .invalidURL:
        return "URL tidak valid"

      case .invalidResponse:
        return "Response server tiak valid."

      case .httpError(let statusCode, _):
        return "Request gagal dengan status code \(statusCode)."

      case .encodingError(let error):
        return "Encoding error \(error.localizedDescription)"

      case .decodingError(let error):
        return "Gagal decode response: \(error.localizedDescription)"

      case .transportError(let error):
        return "Network error: \(error.localizedDescription)"
    }
  }
}
 