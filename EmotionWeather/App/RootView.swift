import SwiftUI

struct RootView: View {
    private let arguments = ProcessInfo.processInfo.arguments
    @State private var selectedTab: AppTab
    @State private var isShowingLoading: Bool

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        _selectedTab = State(initialValue: arguments.contains("--open-shelf") ? .shelf : .today)
        _isShowingLoading = State(initialValue: !arguments.contains("--skip-loading") && !arguments.contains("--weather-gallery"))
    }

    var body: some View {
        ZStack {
            content
                .opacity(isShowingLoading ? 0 : 1)
                .disabled(isShowingLoading)

            if isShowingLoading {
                LoadingView()
                    .transition(.opacity)
            }
        }
        .task {
            await dismissLoadingIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        if arguments.contains("--weather-gallery") {
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

    @MainActor
    private func dismissLoadingIfNeeded() async {
        guard isShowingLoading, !arguments.contains("--hold-loading") else { return }

        try? await Task.sleep(nanoseconds: 1_250_000_000)
        withAnimation(.easeInOut(duration: 0.42)) {
            isShowingLoading = false
        }
    }
}

private enum AppTab {
    case today
    case shelf
    case profile
}

private struct LoadingView: View {
    @State private var isFloating = false
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.weatherSurface, Color(hex: 0xEEF3F2), Color.weatherBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0x7FB6A4).opacity(isGlowing ? 0.20 : 0.12), .clear],
                        center: .center,
                        startRadius: 18,
                        endRadius: 210
                    )
                )
                .frame(width: 420, height: 420)
                .offset(y: -58)

            VStack(spacing: 26) {
                ZStack {
                    WeatherBottleView(
                        kind: .sunny,
                        isSealed: true,
                        compact: false,
                        sealedDate: nil,
                        isCelebrating: isGlowing
                    )
                    .frame(width: 112, height: 194)
                    .scaleEffect(isGlowing ? 1.025 : 0.99)
                    .offset(y: isFloating ? -7 : 4)

                    loadingSparkles
                }
                .frame(width: 190, height: 220)

                VStack(spacing: 10) {
                    Text("天气瓶")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.weatherInk)

                    HStack(spacing: 7) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(index == 1 ? Color(hex: 0x7FB6A4) : Color(hex: 0xE8B94D))
                                .frame(width: 7, height: 7)
                                .opacity(isGlowing ? 0.95 : 0.36)
                                .scaleEffect(isGlowing ? 1.12 : 0.78)
                                .animation(
                                    .easeInOut(duration: 0.9)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.16),
                                    value: isGlowing
                                )
                        }
                    }
                }
            }
            .padding(.bottom, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }

    private var loadingSparkles: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0xE8B94D).opacity(0.72))
                .frame(width: 9, height: 9)
                .offset(x: -58, y: -58)
            Circle()
                .fill(Color.white.opacity(0.88))
                .frame(width: 6, height: 6)
                .offset(x: 62, y: -24)
            Circle()
                .fill(Color(hex: 0x7FB6A4).opacity(0.70))
                .frame(width: 8, height: 8)
                .offset(x: 50, y: 62)
        }
        .blur(radius: isGlowing ? 0 : 0.4)
        .scaleEffect(isGlowing ? 1.08 : 0.94)
        .animation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true), value: isGlowing)
    }
}
