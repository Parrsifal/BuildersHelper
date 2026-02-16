import SwiftUI

struct BudgetOverviewView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var selectedSite: Site?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    totalBudgetCard
                    sitesBreakdown
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(item: $selectedSite) { site in
            SiteBudgetDetailView(siteId: site.id)
        }
    }

    private var totalBudgetCard: some View {
        let progress = storage.totalBudget > 0 ? min(storage.totalSpent / storage.totalBudget, 1.0) : 0

        return VStack(spacing: 14) {
            HStack {
                Label("Total Budget", systemImage: "chart.pie.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "$%.0f", storage.totalSpent))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accent)
                Text(String(format: "/ $%.0f", storage.totalBudget))
                    .font(.callout)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.background)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(storage.totalRemaining >= 0 ? AppTheme.accent : AppTheme.destructive)
                        .frame(width: geo.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                statItem(title: "Total", value: storage.totalBudget, icon: "banknote", color: AppTheme.textPrimary)
                Spacer()
                statItem(title: "Spent", value: storage.totalSpent, icon: "arrow.up.circle", color: AppTheme.accent)
                Spacer()
                statItem(title: "Remaining", value: storage.totalRemaining, icon: "arrow.down.circle", color: storage.totalRemaining >= 0 ? AppTheme.success : AppTheme.destructive)
            }
        }
        .cardStyle()
    }

    private func statItem(title: String, value: Double, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
            Text(String(format: "$%.0f", value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }

    private var sitesBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("By Site", systemImage: "building.2")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }

            if storage.sites.isEmpty {
                Text("No sites yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(storage.sites) { site in
                    Button {
                        selectedSite = site
                    } label: {
                        siteBudgetRow(site)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .cardStyle()
    }

    private func siteBudgetRow(_ site: Site) -> some View {
        let spent = storage.totalSpentForSite(site.id)
        let progress = site.budget > 0 ? min(spent / site.budget, 1.0) : 0
        let remaining = site.budget - spent

        return VStack(spacing: 6) {
            HStack {
                Text(site.name.isEmpty ? "Unnamed" : site.name)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(String(format: "$%.0f / $%.0f", spent, site.budget))
                    .font(.caption)
                    .foregroundColor(remaining >= 0 ? AppTheme.textSecondary : AppTheme.destructive)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.background)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(remaining >= 0 ? AppTheme.accent : AppTheme.destructive)
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BudgetOverviewView()
        .environmentObject(LocalStorage.preview)
}
