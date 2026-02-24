import Foundation

// ============================================================================
// MARK: - APP CONFIGURATION
// ============================================================================

enum AppConfiguration {

    // MARK: - AppsFlyer Configuration
    enum AppsFlyer {
        static let devKey = "pjFCcvBo3rSpvVRbumGgxc"
        static let appleAppID = "6759253180"
    }

    // MARK: - Config Endpoint
    enum Config {
        static let endpoint = "https://buildersmanager.com/config.php"
    }

    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://www.termsfeed.com/live/f29340e4-b99f-4ab0-b8a4-5e5e0a7e3e3e"
        static let support = "https://buildersmanager.com"
    }

    // MARK: - App Store
    enum AppStore {
        static var storeID: String {
            return "id\(AppsFlyer.appleAppID)"
        }
    }

    // MARK: - Bundle Info
    enum Bundle {
        static var bundleID: String {
            return Foundation.Bundle.main.bundleIdentifier ?? "com.buildershelper"
        }

        static var appVersion: String {
            return Foundation.Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        }

        static var buildNumber: String {
            return Foundation.Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        }
    }

    // MARK: - Firebase
    enum Firebase {
        static let projectID = "builders-manager"

        static var projectNumber: String {
            if let path = Foundation.Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let dict = NSDictionary(contentsOfFile: path),
               let gcmSenderID = dict["GCM_SENDER_ID"] as? String {
                return gcmSenderID
            }
            return ""
        }
    }

    // MARK: - Push Notifications
    enum PushNotifications {
        static let retryInterval: TimeInterval = 259200 // 3 days in seconds
    }

    // MARK: - Timeouts
    enum Timeouts {
        static let conversionDataTimeout: TimeInterval = 15
        static let configRequestTimeout: TimeInterval = 30
        static let organicRetryDelay: TimeInterval = 5
    }

    // MARK: - Debug
    enum Debug {
        static var isAppsFlyerDebugEnabled: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }

        static var isLoggingEnabled: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
}

// MARK: - Configuration Validation
extension AppConfiguration {

    static func validate() -> [String] {
        var errors: [String] = []

        if AppsFlyer.devKey == "YOUR_APPSFLYER_DEV_KEY" || AppsFlyer.devKey.isEmpty {
            errors.append("AppsFlyer Dev Key not configured")
        }

        if AppsFlyer.appleAppID == "YOUR_APPLE_APP_ID" || AppsFlyer.appleAppID.isEmpty {
            errors.append("Apple App ID not configured")
        }

        if Config.endpoint == "YOUR_CONFIG_ENDPOINT_URL" || Config.endpoint.isEmpty {
            errors.append("Config Endpoint not configured")
        }

        if Firebase.projectID == "YOUR_FIREBASE_PROJECT_ID" || Firebase.projectID.isEmpty {
            errors.append("Firebase Project ID not configured")
        }

        return errors
    }

    static func printStatus() {
        print("╔════════════════════════════════════════════════════════════╗")
        print("║              APP CONFIGURATION STATUS                      ║")
        print("╠════════════════════════════════════════════════════════════╣")
        print("║ Bundle ID: \(Bundle.bundleID)")
        print("║ App Version: \(Bundle.appVersion) (\(Bundle.buildNumber))")
        print("║ AppsFlyer Dev Key: \(AppsFlyer.devKey.prefix(10))...")
        print("║ Apple App ID: \(AppsFlyer.appleAppID)")
        print("║ Config Endpoint: \(Config.endpoint.prefix(30))...")
        print("╠════════════════════════════════════════════════════════════╣")

        let errors = validate()
        if errors.isEmpty {
            print("║ All configurations are set correctly                    ║")
        } else {
            print("║ Configuration errors found:                             ║")
            errors.forEach { print("║   - \($0)") }
        }

        print("╚════════════════════════════════════════════════════════════╝")
    }
}
