import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var selectedTab: AppTab = .sites
    @State private var showSettings = false

    var body: some View {
        if !storage.hasSeenOnboarding {
            OnboardingView()
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                title: selectedTab.title,
                onSettingsTap: { showSettings = true }
            )

            ZStack {
                switch selectedTab {
                case .sites:
                    SitesListView()
                case .calendar:
                    CalendarView()
                case .budget:
                    BudgetOverviewView()
                case .workers:
                    WorkersListView()
                case .dashboard:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalStorage.preview)
}
