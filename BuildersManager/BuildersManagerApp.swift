import SwiftUI

@main
struct BuildersManagerApp: App {

    var body: some Scene {
        WindowGroup {
            EntryView()
        }
    }
}

struct EntryView: View {
    @StateObject private var storage = LocalStorage()

    var body: some View {
        ContentView()
            .environmentObject(storage)
            .preferredColorScheme(.light)
    }
}

#Preview {
    EntryView()
}
