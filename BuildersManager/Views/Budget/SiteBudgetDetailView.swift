import SwiftUI

struct SiteBudgetDetailView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let siteId: UUID

    @State private var showAddExpense = false

    private var site: Site? { storage.site(by: siteId) }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if let site = site {
                    ScrollView {
                        VStack(spacing: 14) {
                            budgetSummary(site)
                            materialExpenses
                            laborCosts
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showAddExpense) {
            AddExpenseView(siteId: siteId)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(AppTheme.accent)
            }

            Spacer()

            Text(site?.name ?? "Budget")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            Spacer().frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground.ignoresSafeArea(edges: .top))
    }

    private func budgetSummary(_ site: Site) -> some View {
        let materialsCost = storage.totalExpensesForSite(site.id)
        let laborCost = storage.totalLaborCostForSite(site.id)
        let totalSpent = materialsCost + laborCost
        let remaining = site.budget - totalSpent
        let progress = site.budget > 0 ? min(totalSpent / site.budget, 1.0) : 0

        return VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "$%.0f", totalSpent))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accent)
                Text(String(format: "/ $%.0f", site.budget))
                    .font(.callout)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.background)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(remaining >= 0 ? AppTheme.accent : AppTheme.destructive)
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Materials", systemImage: "shippingbox.fill")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f", materialsCost))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    Label("Labor", systemImage: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f", laborCost))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Label("Remaining", systemImage: "arrow.down.circle")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f", remaining))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(remaining >= 0 ? AppTheme.success : AppTheme.destructive)
                }
            }
        }
        .cardStyle()
    }

    private var materialExpenses: some View {
        let siteExpenses = storage.expensesForSite(siteId)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Material Expenses", systemImage: "cart.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Button { showAddExpense = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.accent)
                }
            }

            if siteExpenses.isEmpty {
                Text("No expenses recorded")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(siteExpenses) { expense in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.title)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(expense.date, style: .date)
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(String(format: "-$%.0f", expense.amount))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.destructive)

                        Button {
                            storage.deleteExpense(expense)
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(AppTheme.destructive.opacity(0.6))
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .cardStyle()
    }

    private var laborCosts: some View {
        let siteShifts = storage.shiftsForSite(siteId)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Labor Costs", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(String(format: "$%.0f", storage.totalLaborCostForSite(siteId)))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.accent)
            }

            if siteShifts.isEmpty {
                Text("No shifts recorded")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(siteShifts) { shift in
                    let worker = storage.worker(by: shift.workerId)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(worker?.name ?? "Unknown")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(shift.date, style: .date) · \(String(format: "%.0fh", shift.hours))")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(String(format: "-$%.0f", shift.hours * (worker?.hourlyRate ?? 0)))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.destructive)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    let storage = LocalStorage.preview
    SiteBudgetDetailView(siteId: storage.sites[0].id)
        .environmentObject(storage)
}
