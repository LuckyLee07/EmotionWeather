import SwiftUI

struct RootView: View {
    @State private var selectedTab = ProcessInfo.processInfo.arguments.contains("--open-shelf") ? AppTab.shelf : AppTab.today

    var body: some View {
        if ProcessInfo.processInfo.arguments.contains("--weather-gallery") {
            NavigationStack {
                WeatherGalleryView()
            }
        } else {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(AppTab.today)
                    .tabItem {
                        Label("今天", systemImage: "cloud.sun")
                    }

                ShelfView(startsInMonthMode: ProcessInfo.processInfo.arguments.contains("--open-month-shelf"))
                    .tag(AppTab.shelf)
                    .tabItem {
                        Label("瓶架", systemImage: "tray.full")
                    }

                ProfileView()
                    .tag(AppTab.profile)
                    .tabItem {
                        Label("我的", systemImage: "person")
                    }
            }
            .tint(.weatherInk)
        }
    }
}

private enum AppTab {
    case today
    case shelf
    case profile
}
