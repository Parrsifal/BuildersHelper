import Foundation

struct UserProfile: Codable {
    var name: String
    var company: String

    init(name: String = "", company: String = "") {
        self.name = name
        self.company = company
    }
}
