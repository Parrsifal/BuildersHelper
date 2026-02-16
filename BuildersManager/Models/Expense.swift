import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID
    var siteId: UUID
    var title: String
    var amount: Double
    var date: Date

    init(id: UUID = UUID(), siteId: UUID, title: String = "", amount: Double = 0, date: Date = Date()) {
        self.id = id
        self.siteId = siteId
        self.title = title
        self.amount = amount
        self.date = date
    }
}
