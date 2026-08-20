import Foundation

enum AppConfig {
    static var apiBaseURL: URL {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: s) else {
            fatalError("API_BASE_URL ausente no Info.plist / xcconfig")
        }
        return url
    }
}
