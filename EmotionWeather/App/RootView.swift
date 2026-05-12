import SwiftUI

struct RootView: View {
    var body: some View {
        if ProcessInfo.processInfo.arguments.contains("--weather-gallery") {
            NavigationStack {
                WeatherGalleryView()
            }
        } else {
            TabView {
                TodayView()
                    .tabItem {
                        Label("今天", systemImage: "cloud.sun")
                    }

                ShelfView()
                    .tabItem {
                        Label("瓶架", systemImage: "tray.full")
                    }

                ProfileView()
                    .tabItem {
                        Label("我的", systemImage: "person")
                    }
            }
            .tint(.weatherInk)
        }
    }
}
