import WidgetKit
import UIKit

struct WidgetFcyModel: Codable, Identifiable {
  let id: String
  let currency: String
  let imageData: Data?
  let buyPrice: String
  let sellPrice: String
  let isActive: Bool
}

struct FCYWidgetClient {
  struct FcyRateItem: Decodable {
    let _id: String?
    let image: String?
    let currency: String?
    let retailRateType: String?
    let retailRateDesc: String?
    let buyRate: String?
    let sellRate: String?
    let revaluationRate: String?
    let lastMaintainedAt: String?
    let modifiedAt: String?
    let createdAt: String?
  }

  struct FcyRateResponse: Decodable {
    let status: String?
    let message: String?
    let data: [FcyRateItem]?
  }

  // MARK: - Fetch Foreign Exchange Rates (REST GET)
  static func fetchForeignExchangeRates() async -> [FcyRateItem] {
    // Attempt 1: Decode direct JSON Array [ { ... } ]
    do {
      let items: [FcyRateItem] = try await NetworkClient.shared.request(
        .foreignExchangeRates(),
        responseType: [FcyRateItem].self
      )
      print("[FCYWidgetClient] Direct array decoding succeeded, count:", items.count)
      return sortRates(items)
    } catch {
      print("[FCYWidgetClient] Direct array decoding failed:", error)
    }

    // Attempt 2: Decode JSON Object wrapper { "data": [ { ... } ] } (Hanya jika Attempt 1 gagal)
    do {
      let response: FcyRateResponse = try await NetworkClient.shared.request(
        .foreignExchangeRates(),
        responseType: FcyRateResponse.self
      )
      print("[FCYWidgetClient] Object wrapper decoding succeeded")
      return sortRates(response.data ?? [])
    } catch {
      print("[FCYWidgetClient] Object wrapper decoding failed:", error)
      return []
    }
  }

  private static func sortRates(_ items: [FcyRateItem]) -> [FcyRateItem] {
    items.sorted { item1, item2 in
      let c1 = item1.currency ?? ""
      let c2 = item2.currency ?? ""
      return c1.localizedCaseInsensitiveCompare(c2) == .orderedAscending
    }
  }

  // MARK: - Download Image Helper
  static func fetchImage(from urlString: String) async -> Data? {
    guard let url = URL(string: urlString) else { return nil }
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
      return data
    } catch {
      print("[FCYWidgetClient] fetchImage failed:", error)
      return nil
    }
  }
}
