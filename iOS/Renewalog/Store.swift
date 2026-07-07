import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [RenewalogEntry] = []
    @Published var categoryTogglesEnabled: Bool = true

    /// Free tier item cap. Seed data count is always well below this.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("renewalog_entries.json")
        load()
    }

    var isAtFreeLimit: Bool {
        entries.count >= Store.freeLimit
    }

    func add(_ entry: RenewalogEntry) -> Bool {
        guard !isAtFreeLimit else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: RenewalogEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: RenewalogEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([RenewalogEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.seedData()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static func seedData() -> [RenewalogEntry] {
        (1...3).map { i in
            RenewalogEntry(title: "Sample Contract \(i)", date: Date(), clientName: "Example", termsNote: "—", note: "")
        }
    }
}
