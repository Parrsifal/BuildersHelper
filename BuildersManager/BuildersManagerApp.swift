import SwiftUI

@main
struct BuildersManagerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storage = LocalStorage()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(storage)
                .preferredColorScheme(.light)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(LocalStorage())
        .preferredColorScheme(.light)
}
