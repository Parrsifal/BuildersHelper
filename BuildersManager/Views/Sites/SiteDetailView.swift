import SwiftUI

struct SiteDetailView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let siteId: UUID

    @State private var showEditSite = false
    @State private var showAddExpense = false

    private var site: Site? { storage.site(by: siteId) }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                detailHeader

                if let site = site {
                    ScrollView {
                        VStack(spacing: 16) {
                            siteImageSection(site)
                            budgetCard(site)
                            workersSection(site)
                            expensesSection(site)
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                    Text("Site not found")
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showEditSite) {
            if let site = site {
                SiteEditView(site: site)
            }
        }
        .fullScreenCover(isPresented: $showAddExpense) {
            AddExpenseView(siteId: siteId)
        }
    }

    private var detailHeader: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(AppTheme.accent)
            }

            Spacer()

            Text(site?.name ?? "Site")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            Button { showEditSite = true } label: {
                Text("Edit")
                    .foregroundColor(AppTheme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
    }

    @ViewBuilder
    private func siteImageSection(_ site: Site) -> some View {
        if let data = site.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private func budgetCard(_ site: Site) -> some View {
        let totalSpent = storage.totalSpentForSite(site.id)
        let remaining = site.budget - totalSpent
        let progress = site.budget > 0 ? min(totalSpent / site.budget, 1.0) : 0

        return VStack(spacing: 12) {
            HStack {
                Label("Budget Overview", systemImage: "dollarsign.circle")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
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
                budgetItem(title: "Total", value: site.budget, color: AppTheme.textPrimary)
                Spacer()
                budgetItem(title: "Spent", value: totalSpent, color: AppTheme.accent)
                Spacer()
                budgetItem(title: "Left", value: remaining, color: remaining >= 0 ? AppTheme.success : AppTheme.destructive)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Materials")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f", storage.totalExpensesForSite(site.id)))
                        .font(.caption)
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Labor")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(String(format: "$%.0f", storage.totalLaborCostForSite(site.id)))
                        .font(.caption)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            HStack {
                Text("Deadline")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text(site.deadline, style: .date)
                    .font(.caption)
                    .foregroundColor(site.deadline < Date() ? AppTheme.destructive : AppTheme.textPrimary)
            }
        }
        .cardStyle()
    }

    private func budgetItem(title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
            Text(String(format: "$%.0f", value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }

    private func workersSection(_ site: Site) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Workers (\(site.workerIds.count))", systemImage: "person.2.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }

            let siteWorkers = storage.workersForSite(site)
            if siteWorkers.isEmpty {
                Text("No workers assigned")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(siteWorkers) { worker in
                    HStack(spacing: 10) {
                        workerAvatar(worker)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(worker.name)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(worker.specialization)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(String(format: "$%.0f/hr", worker.hourlyRate))
                            .font(.caption)
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private func workerAvatar(_ worker: Worker) -> some View {
        if let data = worker.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.accent)
                )
        }
    }

    private func expensesSection(_ site: Site) -> some View {
        let siteExpenses = storage.expensesForSite(site.id)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Expenses", systemImage: "cart.fill")
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
                        Text(String(format: "$%.0f", expense.amount))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.destructive)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        storage.deleteExpense(siteExpenses[index])
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    let storage = LocalStorage.preview
    SiteDetailView(siteId: storage.sites[0].id)
        .environmentObject(storage)
}
