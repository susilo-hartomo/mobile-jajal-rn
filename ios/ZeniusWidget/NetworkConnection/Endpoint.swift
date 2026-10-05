import Foundation

struct Endpoint {
  let path: String
  var method: HTTPMethod
  var headers: [String: String]
  var body : Data?

  init (
    path: String = "",
    method: HTTPMethod = .get,
    headers: [String: String] = [:],
    body : Data? = nil
  ) {
    self.path = path
    self.method = method
    self.headers = headers
    self.body = body
  }
}

extension Endpoint {
  static func graphql<Body: Encodable>(
    body: Body
  ) throws -> Endpoint {
    let data: Data

    do {
      data = try JSONEncoder().encode(body)
    } catch {
      throw NetworkError.encodingError(error)
    }
    return Endpoint(
      method: .post,
      headers: [
          "Content-Type": "application/json",
          "Accept": "application/json"
      ],
      body: data
    )
  }
}
 