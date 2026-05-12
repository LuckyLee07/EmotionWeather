import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: WeatherStore
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationStack {
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

                Section("开发") {
                    NavigationLink {
                        WeatherGalleryView()
                    } label: {
                        Label("天气视觉验收", systemImage: "sparkles")
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
            .navigationTitle("我的")
            .alert("清除全部天气瓶？", isPresented: $showClearConfirmation) {
                Button("取消", role: .cancel) {}
                Button("清除", role: .destructive) {
                    store.clearAll()
                }
            } message: {
                Text("这会删除本机保存的全部天气记录。")
            }
        }
    }
}
