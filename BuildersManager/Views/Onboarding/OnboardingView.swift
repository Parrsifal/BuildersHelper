import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    onboardingPage(
                        icon: "building.2.fill",
                        title: "Welcome to\nBuildersManager",
                        subtitle: "Manage your construction sites, workers, budgets and schedules — all in one place."
                    )
                    .tag(0)

                    onboardingPage(
                        icon: "chart.bar.fill",
                        title: "Stay on Track",
                        subtitle: "Track expenses, assign shifts, monitor deadlines and keep every project under control."
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                pageIndicator

                Spacer().frame(height: 30)

                Button {
                    if currentPage < 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        storage.hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.accent)
                        .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func onboardingPage(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(AppTheme.accent)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? AppTheme.accent : AppTheme.textSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LocalStorage.preview)
}
