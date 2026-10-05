import Foundation

private final class WidgetBundleToken {}

enum WidgetNetworkEnvironment {
  static var apiURL: URL {
    // 1. Cek .env dari Bundle resource atau path project root
    var envPaths: [String] = []

    let bundle = Bundle(for: WidgetBundleToken.self)
    if let bundlePath = bundle.path(forResource: ".env", ofType: nil) {
      envPaths.append(bundlePath)
    }
    if let mainBundlePath = Bundle.main.path(forResource: ".env", ofType: nil) {
      envPaths.append(mainBundlePath)
    }

    // Path fallback untuk development / simulator (membaca .env di root project)
    let projectRootEnv = URL(fileURLWithPath: #file)
      .deletingLastPathComponent() // NetworkConnection
      .deletingLastPathComponent() // ZeniusWidget
      .deletingLastPathComponent() // ios
      .deletingLastPathComponent() // project root
      .appendingPathComponent(".env").path
    envPaths.append(projectRootEnv)

    for envPath in envPaths {
      if FileManager.default.fileExists(atPath: envPath),
         let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) {
        for line in envContent.components(separatedBy: .newlines) {
          let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
          if trimmed.hasPrefix("BASE_API_URL=") {
            let value = trimmed.replacingOccurrences(of: "BASE_API_URL=", with: "")
                               .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            if !value.isEmpty, let url = URL(string: value) {
              return url
            }
          }
        }
      }
    }

    // 2. Cek Info.plist jika dikonfigurasi via dynamic build variable $(BASE_API_URL)
    if let envUrlString = Bundle.main.object(forInfoDictionaryKey: "BASE_API_URL") as? String,
       !envUrlString.isEmpty,
       !envUrlString.hasPrefix("$"),
       let url = URL(string: envUrlString) {
      return url
    }

    // 3. Throw fatalError jika BASE_API_URL tidak ditemukan di .env
    fatalError("BASE_API_URL tidak ditemukan di file .env")
  }
}
 