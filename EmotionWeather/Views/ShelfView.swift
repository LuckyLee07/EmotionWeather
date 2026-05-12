import SwiftUI

struct ShelfView: View {
    @EnvironmentObject private var store: WeatherStore
    @State private var mode: ShelfMode = .week
    @State private var selectedDate: Date?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.weatherBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        Picker("瓶架视图", selection: $mode) {
                            ForEach(ShelfMode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 22)

                        if mode == .week {
                            weekShelf
                        } else {
                            monthShelf
                        }

                        summaryBlock
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 34)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: Binding(
                get: {
                    selectedDate.map(SelectedDate.init(date:))
                },
                set: { selectedDate = $0?.date }
            )) { item in
                DayDetailView(date: item.date)
                    .environmentObject(store)
                    .presentationDetents([.height(360)])
            }
        }
    }

    private var weekShelf: some View {
        VStack(spacing: 15) {
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(store.datesForCurrentWeek(), id: \.self) { date in
                    Button {
                        selectedDate = date
                    } label: {
                        ShelfBottleCell(
                            date: date,
                            topLabel: store.weekdayLabel(for: date),
                            bottomLabel: store.dayLabel(for: date),
                            record: store.record(for: date)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)

            shelfLine
                .padding(.horizontal, 24)
        }
    }

    private var monthShelf: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(store.datesForCurrentMonth(), id: \.self) { date in
                Button {
                    selectedDate = date
                } label: {
                    ShelfBottleCell(
                        date: date,
                        topLabel: store.dayLabel(for: date),
                        bottomLabel: nil,
                        record: store.record(for: date),
                        compact: true
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
    }

    private var shelfLine: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0xD8C6AE), Color(hex: 0xF2E6D6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 7)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var summaryBlock: some View {
        Text(store.monthSummaryText())
            .font(.system(size: 16, weight: .regular, design: .serif))
            .lineSpacing(5)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.weatherInk)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Color.weatherSurface.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.weatherLine, lineWidth: 1)
            }
            .padding(.horizontal, 22)
    }
}

private enum ShelfMode: String, CaseIterable, Identifiable {
    case week
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: "本周气候"
        case .month: "本月瓶架"
        }
    }
}

private struct SelectedDate: Identifiable {
    let date: Date
    var id: Date { date }
}

private struct ShelfBottleCell: View {
    let date: Date
    let topLabel: String
    let bottomLabel: String?
    let record: WeatherRecord?
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 5 : 8) {
            Text(topLabel)
                .font(compact ? .caption2.weight(.medium) : .caption.weight(.medium))
                .foregroundStyle(Color.weatherMuted)

            WeatherBottleView(kind: record?.weatherType, isSealed: record != nil, compact: true)
                .frame(height: compact ? 74 : 112)
                .opacity(record == nil ? 0.42 : 1)

            if let bottomLabel {
                Text(bottomLabel)
                    .font(.caption2)
                    .foregroundStyle(Color.weatherMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

private struct DayDetailView: View {
    @EnvironmentObject private var store: WeatherStore
    let date: Date

    var body: some View {
        let record = store.record(for: date)

        VStack(spacing: 18) {
            Capsule()
                .fill(Color.weatherLine)
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            WeatherBottleView(
                kind: record?.weatherType,
                isSealed: record != nil,
                sealedDate: store.displayDate(date)
            )
                .frame(width: 110, height: 190)

            VStack(spacing: 8) {
                Text(store.displayDate(date))
                    .font(.headline)
                    .foregroundStyle(Color.weatherInk)

                if let record {
                    Text("今天的我：\(record.weatherName)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(record.weatherType.primaryColor)

                    Text(record.quote)
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(Color.weatherInk)
                } else {
                    Text("那天没有收集天气。")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(Color.weatherMuted)
                }
            }
            .multilineTextAlignment(.center)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .background(Color.weatherBackground)
    }
}
