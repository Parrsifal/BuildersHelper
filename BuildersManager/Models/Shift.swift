import Foundation

struct Shift: Identifiable, Codable {
    var id: UUID
    var workerId: UUID
    var siteId: UUID
    var date: Date
    var hours: Double

    init(id: UUID = UUID(), workerId: UUID, siteId: UUID, date: Date = Date(), hours: Double = 8) {
        self.id = id
        self.workerId = workerId
        self.siteId = siteId
        self.date = date
        self.hours = hours
    }
}
