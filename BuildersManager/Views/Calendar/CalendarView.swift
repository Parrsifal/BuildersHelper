import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var showAddShift = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                monthNavigation
                weekdayHeader
                calendarGrid
                Divider().padding(.horizontal, 16)
                shiftsList
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button { showAddShift = true } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.accent)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 16)
        }
        .fullScreenCover(isPresented: $showAddShift) {
            AddShiftView(preselectedDate: selectedDate)
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button { changeMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppTheme.accent)
            }

            Spacer()

            Text(monthYearString)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button { changeMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.accent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private var calendarGrid: some View {
        let days = daysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    dayCell(date)
                } else {
                    Text("")
                        .frame(height: 36)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasShifts = !storage.shiftsForDate(date).isEmpty

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : (isToday ? AppTheme.accent : AppTheme.textPrimary))

                Circle()
                    .fill(hasShifts ? (isSelected ? Color.white : AppTheme.accent) : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? AppTheme.accent : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var shiftsList: some View {
        let dayShifts = storage.shiftsForDate(selectedDate)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(dayShifts.count) shift\(dayShifts.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            if dayShifts.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("No shifts scheduled")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(dayShifts) { shift in
                            shiftRow(shift)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 70)
                }
            }
        }
    }

    private func shiftRow(_ shift: Shift) -> some View {
        let worker = storage.worker(by: shift.workerId)
        let site = storage.site(by: shift.siteId)

        return HStack(spacing: 10) {
            Circle()
                .fill(AppTheme.accent.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.accent)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(worker?.name ?? "Unknown Worker")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Text(site?.name ?? "Unknown Site")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0fh", shift.hours))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.accent)
                if let rate = worker?.hourlyRate {
                    Text(String(format: "$%.0f", shift.hours * rate))
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Button {
                storage.deleteShift(shift)
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(AppTheme.destructive.opacity(0.7))
            }
        }
        .cardStyle()
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func changeMonth(_ value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!

        var weekday = calendar.component(.weekday, from: firstDay)
        weekday = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }
}

#Preview {
    CalendarView()
        .environmentObject(LocalStorage.preview)
}
