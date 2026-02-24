import SwiftUI

struct LoadingView: View {
    @ObservedObject var appStateManager = AppStateManager.shared

    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.primaryColor))
                    .scaleEffect(2.0)

                VStack(spacing: 8) {
                    Text(appStateManager.loadingProgress)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)

                    Text("Please wait")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoadingView()
}
