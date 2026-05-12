import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject private var store: WeatherStore
    @StateObject private var reminderStore = ReminderSettingsStore()
    @State private var showClearConfirmation = false
    @State private var showDemoDataMessage = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("我的天气瓶")
                                    .font(.headline)
                                Text("你的天气，只属于你。")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.weatherMuted)
                            }

                            Spacer()

                            Text("\(store.totalRecordCount)")
                                .font(.system(size: 34, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.weatherInk)
                        }
                        .padding(.vertical, 8)
                    }

                    Section("设置") {
                        Label("默认玻璃瓶", systemImage: "testtube.2")
                        Label("分享时显示日期", systemImage: "calendar")
                        Label("本地保存", systemImage: "lock")
                    }

                    Section("提醒") {
                        Toggle(isOn: Binding(
                            get: { reminderStore.isEnabled },
                            set: { reminderStore.setEnabled($0) }
                        )) {
                            Label("每天提醒我记录", systemImage: "bell.badge")
                        }

                        DatePicker(
                            "提醒时间",
                            selection: Binding(
                                get: { reminderStore.reminderDate },
                                set: { reminderStore.setReminderDate($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .disabled(!reminderStore.isEnabled)

                        Text(reminderStore.statusText)
                            .font(.caption)
                            .foregroundStyle(Color.weatherMuted)
                    }

                    Section("开发") {
                        NavigationLink {
                            WeatherGalleryView()
                        } label: {
                            Label("天气视觉验收", systemImage: "sparkles")
                        }

                        Button {
                            store.seedCurrentMonthDemoData()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                showDemoDataMessage = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeOut(duration: 0.24)) {
                                    showDemoDataMessage = false
                                }
                            }
                        } label: {
                            Label("生成本月演示数据", systemImage: "wand.and.stars")
                        }
                    }

                    Section("数据") {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("清除全部天气瓶", systemImage: "trash")
                        }
                    }

                    Section("关于") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("天气瓶")
                                .font(.headline)
                            Text("一个用天气记录心情的极简情绪收藏 App。")
                                .foregroundStyle(Color.weatherMuted)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.weatherBackground)

                if showDemoDataMessage {
                    VStack {
                        Spacer()
                        Text("本月演示天气已经放入瓶架。")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(Color.weatherInk)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
                            .padding(.bottom, 24)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("我的")
            .alert("清除全部天气瓶？", isPresented: $showClearConfirmation) {
                Button("取消", role: .cancel) {}
                Button("清除", role: .destructive) {
                    store.clearAll()
                }
            } message: {
                Text("这会删除本机保存的全部天气记录。")
            }
            .task {
                await reminderStore.refreshAuthorizationStatus()
            }
        }
    }
}

@MainActor
private final class ReminderSettingsStore: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var statusText: String
    @Published var reminderDate: Date

    private let notificationID = "daily-weather-bottle-reminder"
    private let enabledKey = "ReminderSettings.isEnabled"
    private let hourKey = "ReminderSettings.hour"
    private let minuteKey = "ReminderSettings.minute"

    init() {
        let defaults = UserDefaults.standard
        let savedIsEnabled = defaults.bool(forKey: enabledKey)

        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = defaults.object(forKey: hourKey) as? Int ?? 21
        components.minute = defaults.object(forKey: minuteKey) as? Int ?? 0
        let savedReminderDate = Calendar.current.date(from: components) ?? Date()

        isEnabled = savedIsEnabled
        reminderDate = savedReminderDate
        statusText = savedIsEnabled ? "每天 \(Self.timeText(for: savedReminderDate)) 提醒你记录天气。" : "提醒已关闭。"
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            Task {
                await enableReminder()
            }
        } else {
            isEnabled = false
            persist()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
            statusText = "提醒已关闭。"
        }
    }

    func setReminderDate(_ date: Date) {
        reminderDate = date
        persist()

        if isEnabled {
            Task {
                await scheduleReminder()
            }
        } else {
            statusText = "提醒已关闭。"
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if isEnabled {
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                statusText = "每天 \(Self.timeText(for: reminderDate)) 提醒你记录天气。"
            case .denied:
                statusText = "通知权限未开启，请到系统设置里允许通知。"
            default:
                statusText = "开启后会请求通知权限。"
            }
        }
    }

    private func enableReminder() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        let isAuthorized: Bool
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
        case .denied:
            isAuthorized = false
        default:
            isAuthorized = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        }

        guard isAuthorized else {
            isEnabled = false
            persist()
            statusText = "通知权限未开启，请到系统设置里允许通知。"
            return
        }

        isEnabled = true
        persist()
        await scheduleReminder()
    }

    private func scheduleReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])

        let content = UNMutableNotificationContent()
        content.title = "今天的天气还没封存"
        content.body = "花十秒，把今天的自己放进天气瓶。"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        do {
            try await center.add(request)
            statusText = "每天 \(Self.timeText(for: reminderDate)) 提醒你记录天气。"
        } catch {
            statusText = "提醒保存失败，请稍后再试。"
        }
    }

    private func persist() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        let defaults = UserDefaults.standard
        defaults.set(isEnabled, forKey: enabledKey)
        defaults.set(components.hour ?? 21, forKey: hourKey)
        defaults.set(components.minute ?? 0, forKey: minuteKey)
    }

    private static func timeText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
