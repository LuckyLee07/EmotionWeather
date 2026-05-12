import SwiftUI

struct ShelfView: View {
    @EnvironmentObject private var store: WeatherStore
    @State private var mode: ShelfMode
    @State private var selectedDate: Date?
    @State private var selectedMonth = Date()

    init(startsInMonthMode: Bool = false) {
        _mode = State(initialValue: startsInMonthMode ? .month : .week)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.weatherBackground, Color(hex: 0xEEF3F2), Color.weatherSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
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
                            monthHeader
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
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { label in
                    Text(label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.weatherMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 2)

            ForEach(Array(monthRows.enumerated()), id: \.offset) { _, row in
                VStack(spacing: 5) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, date in
                            if let date {
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
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 96)
                            }
                        }
                    }

                    shelfLine
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 2)
    }

    private var monthRows: [[Date?]] {
        let dates = store.datesForMonth(containing: selectedMonth)
        guard let firstDate = dates.first else { return [] }

        let weekday = Calendar.current.component(.weekday, from: firstDate)
        let leadingBlankCount = (weekday + 5) % 7
        let filledSlots: [Date?] = Array(repeating: nil, count: leadingBlankCount) + dates.map(Optional.some)
        let trailingBlankCount = (7 - filledSlots.count % 7) % 7
        let allSlots = filledSlots + Array(repeating: nil, count: trailingBlankCount)

        return stride(from: 0, to: allSlots.count, by: 7).map { start in
            Array(allSlots[start..<min(start + 7, allSlots.count)])
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    selectedMonth = store.monthByAdding(-1, to: selectedMonth)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.weatherInk)

            VStack(spacing: 4) {
                Text(store.monthTitle(for: selectedMonth))
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.weatherInk)

                Text("把这个月的天气陈列起来")
                    .font(.caption)
                    .foregroundStyle(Color.weatherMuted)
            }
            .frame(maxWidth: .infinity)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    selectedMonth = store.monthByAdding(1, to: selectedMonth)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
            .foregroundStyle(store.canMoveToNextMonth(from: selectedMonth) ? Color.weatherInk : Color.weatherMuted.opacity(0.45))
            .disabled(!store.canMoveToNextMonth(from: selectedMonth))
        }
        .padding(.horizontal, 22)
    }

    private var shelfLine: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0xCDB79B), Color(hex: 0xF2E6D6), Color(hex: 0xD8C6AE)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 6)
            .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 4)
    }

    private var summaryBlock: some View {
        Text(store.monthSummaryText(for: mode == .month ? selectedMonth : Date()))
            .font(.system(size: 16, weight: .regular, design: .serif))
            .lineSpacing(5)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.weatherInk)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.weatherSurface.opacity(0.78), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
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

            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.weatherSurface.opacity(0.70))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(record?.weatherType.primaryColor.opacity(0.22) ?? Color.weatherLine, lineWidth: 1)
                    }

                WeatherBottleView(
                    kind: record?.weatherType,
                    isSealed: record != nil,
                    sealedDate: store.displayDate(date)
                )
                    .frame(width: 116, height: 200)
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: 210)

            VStack(spacing: 8) {
                Text(store.fullDisplayDate(date))
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
