import Foundation

struct RenewalogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date = Date()
    var clientName: String = ""
    var termsNote: String = ""
    var note: String = ""
}
