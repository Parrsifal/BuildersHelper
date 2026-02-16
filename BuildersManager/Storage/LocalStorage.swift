import Foundation
import Combine
import SwiftUI

class LocalStorage: ObservableObject {

    // MARK: - Published Properties

    @Published var sites: [Site] = [] {
        didSet { save(sites, forKey: "sites") }
    }

    @Published var workers: [Worker] = [] {
        didSet { save(workers, forKey: "workers") }
    }

    @Published var shifts: [Shift] = [] {
        didSet { save(shifts, forKey: "shifts") }
    }

    @Published var expenses: [Expense] = [] {
        didSet { save(expenses, forKey: "expenses") }
    }

    @Published var profile: UserProfile = UserProfile() {
        didSet { save(profile, forKey: "profile") }
    }

    @Published var hasSeenOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding") }
    }

    // MARK: - Init

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        self.sites = load(forKey: "sites") ?? []
        self.workers = load(forKey: "workers") ?? []
        self.shifts = load(forKey: "shifts") ?? []
        self.expenses = load(forKey: "expenses") ?? []
        self.profile = load(forKey: "profile") ?? UserProfile()
    }

    // MARK: - Sites CRUD

    func addSite(_ site: Site) {
        sites.append(site)
    }

    func updateSite(_ site: Site) {
        if let index = sites.firstIndex(where: { $0.id == site.id }) {
            sites[index] = site
        }
    }

    func deleteSite(_ site: Site) {
        sites.removeAll { $0.id == site.id }
        shifts.removeAll { $0.siteId == site.id }
        expenses.removeAll { $0.siteId == site.id }
    }

    func site(by id: UUID) -> Site? {
        sites.first { $0.id == id }
    }

    // MARK: - Workers CRUD

    func addWorker(_ worker: Worker) {
        workers.append(worker)
    }

    func updateWorker(_ worker: Worker) {
        if let index = workers.firstIndex(where: { $0.id == worker.id }) {
            workers[index] = worker
        }
    }

    func deleteWorker(_ worker: Worker) {
        workers.removeAll { $0.id == worker.id }
        shifts.removeAll { $0.workerId == worker.id }
        for i in sites.indices {
            sites[i].workerIds.removeAll { $0 == worker.id }
        }
    }

    func worker(by id: UUID) -> Worker? {
        workers.first { $0.id == id }
    }

    // MARK: - Shifts CRUD

    func addShift(_ shift: Shift) {
        shifts.append(shift)
    }

    func updateShift(_ shift: Shift) {
        if let index = shifts.firstIndex(where: { $0.id == shift.id }) {
            shifts[index] = shift
        }
    }

    func deleteShift(_ shift: Shift) {
        shifts.removeAll { $0.id == shift.id }
    }

    func shiftsForSite(_ siteId: UUID) -> [Shift] {
        shifts.filter { $0.siteId == siteId }
    }

    func shiftsForWorker(_ workerId: UUID) -> [Shift] {
        shifts.filter { $0.workerId == workerId }
    }

    func shiftsForDate(_ date: Date) -> [Shift] {
        let calendar = Calendar.current
        return shifts.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    // MARK: - Expenses CRUD

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }

    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        }
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }

    func expensesForSite(_ siteId: UUID) -> [Expense] {
        expenses.filter { $0.siteId == siteId }
    }

    // MARK: - Computed Helpers

    func workersForSite(_ site: Site) -> [Worker] {
        site.workerIds.compactMap { id in worker(by: id) }
    }

    func sitesForWorker(_ worker: Worker) -> [Site] {
        sites.filter { $0.workerIds.contains(worker.id) }
    }

    func totalExpensesForSite(_ siteId: UUID) -> Double {
        expensesForSite(siteId).reduce(0) { $0 + $1.amount }
    }

    func totalLaborCostForSite(_ siteId: UUID) -> Double {
        shiftsForSite(siteId).reduce(0) { total, shift in
            let rate = worker(by: shift.workerId)?.hourlyRate ?? 0
            return total + (shift.hours * rate)
        }
    }

    func totalSpentForSite(_ siteId: UUID) -> Double {
        totalExpensesForSite(siteId) + totalLaborCostForSite(siteId)
    }

    func remainingBudgetForSite(_ siteId: UUID) -> Double {
        guard let site = site(by: siteId) else { return 0 }
        return site.budget - totalSpentForSite(siteId)
    }

    var totalBudget: Double {
        sites.reduce(0) { $0 + $1.budget }
    }

    var totalSpent: Double {
        sites.reduce(0) { $0 + totalSpentForSite($1.id) }
    }

    var totalRemaining: Double {
        totalBudget - totalSpent
    }

    // MARK: - Preview

    static var preview: LocalStorage {
        let storage = LocalStorage()

        let worker1 = Worker(name: "John Smith", specialization: "Electrician", education: "Technical College", experience: "5 years in residential wiring", hourlyRate: 35)
        let worker2 = Worker(name: "Mike Johnson", specialization: "Plumber", education: "Trade School", experience: "8 years in commercial plumbing", hourlyRate: 40)
        let worker3 = Worker(name: "Alex Brown", specialization: "Carpenter", education: "Apprenticeship", experience: "3 years in framing", hourlyRate: 30)

        storage.workers = [worker1, worker2, worker3]

        let site1 = Site(name: "Downtown Office", deadline: Date().addingTimeInterval(86400 * 30), budget: 150000, workerIds: [worker1.id, worker2.id])
        let site2 = Site(name: "Riverside Apartments", deadline: Date().addingTimeInterval(86400 * 60), budget: 320000, workerIds: [worker2.id, worker3.id])
        let site3 = Site(name: "Mall Renovation", deadline: Date().addingTimeInterval(86400 * 7), budget: 85000, workerIds: [worker1.id])

        storage.sites = [site1, site2, site3]

        storage.expenses = [
            Expense(siteId: site1.id, title: "Concrete mix", amount: 4500, date: Date().addingTimeInterval(-86400 * 5)),
            Expense(siteId: site1.id, title: "Electrical wiring", amount: 2200, date: Date().addingTimeInterval(-86400 * 3)),
            Expense(siteId: site2.id, title: "Lumber delivery", amount: 8700, date: Date().addingTimeInterval(-86400 * 2)),
            Expense(siteId: site3.id, title: "Paint supplies", amount: 1200, date: Date()),
        ]

        storage.shifts = [
            Shift(workerId: worker1.id, siteId: site1.id, date: Date(), hours: 8),
            Shift(workerId: worker2.id, siteId: site1.id, date: Date(), hours: 6),
            Shift(workerId: worker2.id, siteId: site2.id, date: Date().addingTimeInterval(-86400), hours: 8),
            Shift(workerId: worker3.id, siteId: site2.id, date: Date(), hours: 4),
            Shift(workerId: worker1.id, siteId: site3.id, date: Date().addingTimeInterval(86400), hours: 8),
        ]

        storage.profile = UserProfile(name: "David Miller", company: "Miller Construction")
        storage.hasSeenOnboarding = true
        return storage
    }

    // MARK: - Persistence

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
