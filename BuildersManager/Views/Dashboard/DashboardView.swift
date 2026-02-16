import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var storage: LocalStorage

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    overviewCards
                    budgetOverview
                    upcomingDeadlines
                    recentExpenses
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
    }

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            metricCard(title: "Active Sites", value: "\(storage.sites.count)", icon: "building.2.fill", color: AppTheme.accent)
            metricCard(title: "Workers", value: "\(storage.workers.count)", icon: "person.2.fill", color: Color(red: 0.35, green: 0.55, blue: 0.9))
            metricCard(title: "Total Budget", value: formatCompact(storage.totalBudget), icon: "banknote.fill", color: AppTheme.success)
            metricCard(title: "Total Spent", value: formatCompact(storage.totalSpent), icon: "arrow.up.right", color: AppTheme.destructive)
        }
    }

    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .cardStyle()
    }

    private var budgetOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Budget Health", systemImage: "heart.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            let progress = storage.totalBudget > 0 ? min(storage.totalSpent / storage.totalBudget, 1.0) : 0
            let percentage = Int(progress * 100)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.background, lineWidth: 6)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(storage.totalRemaining >= 0 ? AppTheme.accent : AppTheme.destructive, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    Text("\(percentage)%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "$%.0f spent of $%.0f", storage.totalSpent, storage.totalBudget))
                        .font(.caption)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(String(format: "$%.0f remaining", storage.totalRemaining))
                        .font(.caption)
                        .foregroundColor(storage.totalRemaining >= 0 ? AppTheme.success : AppTheme.destructive)
                }

                Spacer()
            }
        }
        .cardStyle()
    }

    private var upcomingDeadlines: some View {
        let upcoming = storage.sites
            .filter { $0.deadline >= Date() }
            .sorted { $0.deadline < $1.deadline }
            .prefix(5)

        return VStack(alignment: .leading, spacing: 10) {
            Label("Upcoming Deadlines", systemImage: "calendar.badge.exclamationmark")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            if upcoming.isEmpty {
                Text("No upcoming deadlines")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(Array(upcoming)) { site in
                    HStack {
                        Circle()
                            .fill(daysUntil(site.deadline) <= 7 ? AppTheme.destructive : AppTheme.accent)
                            .frame(width: 8, height: 8)
                        Text(site.name)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(site.deadline, style: .date)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var recentExpenses: some View {
        let recent = storage.expenses
            .sorted { $0.date > $1.date }
            .prefix(5)

        return VStack(alignment: .leading, spacing: 10) {
            Label("Recent Expenses", systemImage: "receipt.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            if recent.isEmpty {
                Text("No expenses recorded")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(Array(recent)) { expense in
                    let siteName = storage.site(by: expense.siteId)?.name ?? "Unknown"
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.title)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                            Text(siteName)
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(String(format: "-$%.0f", expense.amount))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.destructive)
                    }
                }
            }
        }
        .cardStyle()
    }

    private func formatCompact(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return String(format: "$%.0f", value)
    }

    private func daysUntil(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}

#Preview {
    DashboardView()
        .environmentObject(LocalStorage.preview)
}
