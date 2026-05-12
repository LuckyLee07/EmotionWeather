import Foundation

struct WeatherRecord: Identifiable, Codable, Equatable {
    var id: String
    var date: String
    var weatherType: WeatherKind
    var weatherName: String
    var quote: String
    var note: String?
    var bottleStyle: String
    var createdAt: Date
    var updatedAt: Date

    init(
        date: Date,
        weatherType: WeatherKind,
        note: String? = nil,
        replacesNote: Bool = false,
        existing: WeatherRecord? = nil
    ) {
        let key = DateKey.formatter.string(from: date)
        self.id = key
        self.date = key
        self.weatherType = weatherType
        self.weatherName = weatherType.name
        self.quote = weatherType.quote
        self.note = replacesNote ? WeatherRecord.normalizedNote(note) : (WeatherRecord.normalizedNote(note) ?? existing?.note)
        self.bottleStyle = existing?.bottleStyle ?? "default"
        self.createdAt = existing?.createdAt ?? Date()
        self.updatedAt = Date()
    }

    var dateValue: Date {
        DateKey.formatter.date(from: date) ?? Date()
    }

    var displayNote: String? {
        WeatherRecord.normalizedNote(note)
    }

    static func normalizedNote(_ note: String?) -> String? {
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum DateKey {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
