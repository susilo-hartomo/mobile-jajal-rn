import Foundation

private final class WidgetBundleToken {}

enum WidgetNetworkEnvironment {
  static var apiURL: URL {
    var envPaths: [String] = []

    let bundle = Bundle(for: WidgetBundleToken.self)
    if let bundlePath = bundle.path(forResource: ".env", ofType: nil) {
      envPaths.append(bundlePath)
    }
    if let mainBundlePath = Bundle.main.path(forResource: ".env", ofType: nil) {
      envPaths.append(mainBundlePath)
    }

    let projectRootEnv = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
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

    if let envUrlString = Bundle.main.object(forInfoDictionaryKey: "BASE_API_URL") as? String,
      !envUrlString.isEmpty,
      !envUrlString.hasPrefix("$"),
      let url = URL(string: envUrlString) {
      return url
    }

    fatalError("BASE_API_URL tidak ditemukan di file .env")
  }
}