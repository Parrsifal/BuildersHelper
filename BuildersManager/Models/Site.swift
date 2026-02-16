import Foundation

struct Site: Identifiable, Codable {
    var id: UUID
    var name: String
    var imageData: Data?
    var deadline: Date
    var budget: Double
    var workerIds: [UUID]

    init(id: UUID = UUID(), name: String = "", imageData: Data? = nil, deadline: Date = Date(), budget: Double = 0, workerIds: [UUID] = []) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.deadline = deadline
        self.budget = budget
        self.workerIds = workerIds
    }
}
