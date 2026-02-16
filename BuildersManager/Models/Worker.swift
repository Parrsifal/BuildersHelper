import Foundation

struct Worker: Identifiable, Codable {
    var id: UUID
    var name: String
    var specialization: String
    var education: String
    var experience: String
    var hourlyRate: Double
    var photoData: Data?

    init(id: UUID = UUID(), name: String = "", specialization: String = "", education: String = "", experience: String = "", hourlyRate: Double = 0, photoData: Data? = nil) {
        self.id = id
        self.name = name
        self.specialization = specialization
        self.education = education
        self.experience = experience
        self.hourlyRate = hourlyRate
        self.photoData = photoData
    }
}
