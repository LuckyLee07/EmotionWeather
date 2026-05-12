import SwiftUI

enum WeatherKind: String, CaseIterable, Identifiable, Codable {
    case sunny
    case fog
    case rain
    case thunder
    case snow
    case wind
    case sunset
    case moon

    var id: String { rawValue }

    var name: String {
        switch self {
        case .sunny: "晴"
        case .fog: "雾"
        case .rain: "雨"
        case .thunder: "雷"
        case .snow: "雪"
        case .wind: "风"
        case .sunset: "晚霞"
        case .moon: "月夜"
        }
    }

    var quote: String {
        switch self {
        case .sunny: "今天的光，刚刚好。"
        case .fog: "看不清也没关系，慢一点。"
        case .rain: "有些情绪，也需要落下来。"
        case .thunder: "心里有声音，也是一种天气。"
        case .snow: "安静一点，也很好。"
        case .wind: "你正在经过变化。"
        case .sunset: "今天有一点温柔，值得留下。"
        case .moon: "清醒的人，也需要被照亮。"
        }
    }

    var emotionHint: String {
        switch self {
        case .sunny: "明亮、轻松、平稳"
        case .fog: "迷茫、迟钝、不确定"
        case .rain: "低落、柔软、释放"
        case .thunder: "烦躁、压抑、爆发"
        case .snow: "安静、疏离、冷静"
        case .wind: "不安、变化、流动"
        case .sunset: "温柔、怀念、满足"
        case .moon: "孤独、清醒、沉思"
        }
    }

    var symbolName: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .fog: "cloud.fog.fill"
        case .rain: "cloud.rain.fill"
        case .thunder: "cloud.bolt.rain.fill"
        case .snow: "snowflake"
        case .wind: "wind"
        case .sunset: "sun.haze.fill"
        case .moon: "moon.stars.fill"
        }
    }

    var primaryColor: Color {
        switch self {
        case .sunny: Color(hex: 0xE8B94D)
        case .fog: Color(hex: 0xA9B8C3)
        case .rain: Color(hex: 0x6E9FBD)
        case .thunder: Color(hex: 0x5C4B85)
        case .snow: Color(hex: 0xBFD9EA)
        case .wind: Color(hex: 0x7FB6A4)
        case .sunset: Color(hex: 0xE88E77)
        case .moon: Color(hex: 0x4C6597)
        }
    }

    var backgroundColors: [Color] {
        switch self {
        case .sunny:
            [Color(hex: 0xFFF8D8), Color(hex: 0xF4D47C), Color(hex: 0xF9F2E7)]
        case .fog:
            [Color(hex: 0xEDF2F3), Color(hex: 0xBFCBD2), Color(hex: 0xF7F9F8)]
        case .rain:
            [Color(hex: 0xD9EAF1), Color(hex: 0x7FA9C8), Color(hex: 0x345B73)]
        case .thunder:
            [Color(hex: 0x2F2B47), Color(hex: 0x5C4B85), Color(hex: 0x141722)]
        case .snow:
            [Color(hex: 0xF8FCFF), Color(hex: 0xCFE1EC), Color(hex: 0xEEF5F8)]
        case .wind:
            [Color(hex: 0xE8F4EE), Color(hex: 0x8BC5B1), Color(hex: 0xD6DFDD)]
        case .sunset:
            [Color(hex: 0xFFE3B3), Color(hex: 0xEF9A86), Color(hex: 0xA78AC2)]
        case .moon:
            [Color(hex: 0x172139), Color(hex: 0x304B78), Color(hex: 0x91A5C6)]
        }
    }
}

extension Color {
    static let weatherBackground = Color(hex: 0xF7F3EC)
    static let weatherSurface = Color(hex: 0xFFFCF6)
    static let weatherInk = Color(hex: 0x2D3340)
    static let weatherMuted = Color(hex: 0x7A7D84)
    static let weatherLine = Color(hex: 0xE7DDD0)

    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
