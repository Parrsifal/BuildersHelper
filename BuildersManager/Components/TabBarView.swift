import SwiftUI

enum AppTab: Int, CaseIterable {
    case sites
    case calendar
    case budget
    case workers
    case dashboard

    var title: String {
        switch self {
        case .sites: return "Sites"
        case .calendar: return "Calendar"
        case .budget: return "Budget"
        case .workers: return "Workers"
        case .dashboard: return "Dashboard"
        }
    }

    var icon: String {
        switch self {
        case .sites: return "building.2.fill"
        case .calendar: return "calendar"
        case .budget: return "chart.bar.fill"
        case .workers: return "person.2.fill"
        case .dashboard: return "square.grid.2x2.fill"
        }
    }
}

struct TabBarView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? AppTheme.accent : AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
        .background(
            AppTheme.cardBackground
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

//#Preview {
//    TabBarView(selectedTab: .constant(.sites))
//}


#Preview {
    ContentView()
        .environmentObject(LocalStorage.preview)
}
