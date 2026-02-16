import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var storage: LocalStorage
    @Environment(\.dismiss) private var dismiss

    let siteId: UUID

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        titleSection
                        amountSection
                        dateSection
                    }
                    .padding(16)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .foregroundColor(AppTheme.accent)

            Spacer()

            Text("Add Expense")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button("Save") { save() }
                .foregroundColor(canSave ? AppTheme.accent : AppTheme.textSecondary)
                .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("What was purchased", text: $title)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount ($)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("0", text: $amount)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
        }
    }

    private var canSave: Bool {
        !title.isEmpty && (Double(amount) ?? 0) > 0
    }

    private func save() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        let expense = Expense(siteId: siteId, title: title, amount: amountValue, date: date)
        storage.addExpense(expense)
        dismiss()
    }
}

#Preview {
    let storage = LocalStorage.preview
    AddExpenseView(siteId: storage.sites[0].id)
        .environmentObject(storage)
}
