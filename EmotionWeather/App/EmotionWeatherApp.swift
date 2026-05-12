import SwiftUI

@main
struct EmotionWeatherApp: App {
    @StateObject private var store = WeatherStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .task {
                    if ProcessInfo.processInfo.arguments.contains("--seed-demo") {
                        store.seedCurrentMonthDemoData()
                    }
                }
        }
    }
}
