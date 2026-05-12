import Foundation

@MainActor
final class WeatherStore: ObservableObject {
    @Published private(set) var records: [String: WeatherRecord] = [:]

    private let calendar = Calendar.current
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    var todayKey: String {
        key(for: Date())
    }

    var todayRecord: WeatherRecord? {
        records[todayKey]
    }

    var totalRecordCount: Int {
        records.count
    }

    func record(for date: Date) -> WeatherRecord? {
        records[key(for: date)]
    }

    func save(_ weatherType: WeatherKind, on date: Date = Date()) {
        let key = key(for: date)
        let record = WeatherRecord(date: date, weatherType: weatherType, existing: records[key])
        records[key] = record
        persist()
    }

    func clearAll() {
        records = [:]
        persist()
    }

    func datesForCurrentWeek() -> [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    func datesForCurrentMonth() -> [Date] {
        let today = Date()
        guard let interval = calendar.dateInterval(of: .month, for: today) else {
            return [today]
        }

        let dayCount = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
        return (0..<dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    func monthSummaryText() -> String {
        let monthRecords = datesForCurrentMonth().compactMap { record(for: $0) }
        guard !monthRecords.isEmpty else {
            return "这个月，还没有收集天气。"
        }

        let grouped = Dictionary(grouping: monthRecords, by: \.weatherType)
        let sorted = grouped
            .map { ($0.key, $0.value.count) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    lhs.0.name < rhs.0.name
                } else {
                    lhs.1 > rhs.1
                }
            }

        let countText = sorted
            .prefix(4)
            .map { "\($0.1) 个\($0.0.name)" }
            .joined(separator: "，")

        let leading = sorted.first?.0
        let poetic: String
        switch leading {
        case .sunny: poetic = "这个月的你，大多明亮，也偶尔有别的天气。"
        case .rain: poetic = "这个月的雨季长了一些，也被好好收起来了。"
        case .fog: poetic = "这个月有些雾，但时间仍在慢慢往前。"
        case .thunder: poetic = "这个月有一些响亮的天气，也都过去了。"
        case .snow: poetic = "这个月安静的天气多了一点。"
        case .wind: poetic = "这个月的风多了一些，你正在经过变化。"
        case .sunset: poetic = "这个月留下了不少温柔的晚霞。"
        case .moon: poetic = "这个月的夜色多了一点，也有微光。"
        case nil: poetic = "这个月，你收集了许多种自己。"
        }

        return "这个月，你收集了 \(countText)。\n\(poetic)"
    }

    func weekdayLabel(for date: Date) -> String {
        let index = calendar.component(.weekday, from: date)
        return ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][index - 1]
    }

    func dayLabel(for date: Date) -> String {
        String(calendar.component(.day, from: date))
    }

    func displayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private func key(for date: Date) -> String {
        DateKey.formatter.string(from: calendar.startOfDay(for: date))
    }

    private func load() {
        guard let data = try? Data(contentsOf: storeURL) else {
            records = [:]
            return
        }

        do {
            let decoded = try decoder.decode([String: WeatherRecord].self, from: data)
            records = decoded
        } catch {
            records = [:]
        }
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(
                at: storeURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(records)
            try data.write(to: storeURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist weather records: \(error)")
        }
    }

    private var storeURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return baseURL
            .appendingPathComponent("EmotionWeather", isDirectory: true)
            .appendingPathComponent("weather-records.json")
    }
}
