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
                            summaryBlock
                        } else {
                            monthHeader
                            summaryBlock
                            monthShelf
                        }
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
                    .presentationDetents([.fraction(0.72), .large])
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
        MonthReviewCard(review: store.monthReview(for: mode == .month ? selectedMonth : Date()))
            .padding(.horizontal, 22)
    }
}

private struct MonthReviewCard: View {
    let review: MonthReview

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(review.shortMonthTitle)回顾")
                        .font(.headline)
                        .foregroundStyle(Color.weatherInk)

                    Text(review.distributionText)
                        .font(.caption)
                        .foregroundStyle(Color.weatherMuted)
                        .lineLimit(1)
                }

                Spacer()

                if let dominantWeather = review.dominantWeather {
                    Label(dominantWeather.name, systemImage: dominantWeather.symbolName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(dominantWeather.primaryColor)
                }
            }

            HStack(spacing: 8) {
                MonthMetricPill(title: "记录", value: "\(review.recordedCount)/\(review.totalDays)")
                MonthMetricPill(title: "进度", value: review.progressText)
                MonthMetricPill(title: "连续", value: "\(review.longestStreak)天")
                MonthMetricPill(title: "备注", value: "\(review.noteCount)条")
            }

            Text(review.summaryText)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .lineSpacing(5)
                .foregroundStyle(Color.weatherInk)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.weatherSurface.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.weatherLine, lineWidth: 1)
        }
    }
}

private struct MonthMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.weatherInk)

            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.weatherMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.weatherBackground.opacity(0.68), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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

    @State private var isEditing = false
    @State private var draftKind: WeatherKind = .sunny
    @State private var draftNote = ""

    var body: some View {
        let record = store.record(for: date)

        ScrollView(showsIndicators: false) {
            VStack(spacing: isEditing ? 14 : 18) {
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
                        kind: isEditing ? draftKind : record?.weatherType,
                        isSealed: record != nil || isEditing,
                        sealedDate: store.displayDate(date)
                    )
                    .frame(width: isEditing ? 104 : 116, height: isEditing ? 178 : 200)
                    .padding(.vertical, isEditing ? 8 : 12)
                }
                .frame(maxWidth: 210)

                VStack(spacing: 8) {
                    Text(store.fullDisplayDate(date))
                        .font(.headline)
                        .foregroundStyle(Color.weatherInk)

                    if let record, !isEditing {
                        Text("今天的我：\(record.weatherName)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(record.weatherType.primaryColor)

                        Text(record.quote)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(Color.weatherInk)

                        noteText(record.displayNote)
                    } else if !isEditing {
                        Text("那天没有收集天气。")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(Color.weatherMuted)
                    }
                }
                .multilineTextAlignment(.center)

                if isEditing {
                    editBlock
                }

                Button {
                    if isEditing {
                        store.save(draftKind, on: date, note: draftNote, replacesNote: true)
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            isEditing = false
                        }
                    } else {
                        syncDraft(from: record)
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            isEditing = true
                        }
                    }
                } label: {
                    Label(isEditing ? "保存这天" : (record == nil ? "补记这天" : "修改记录"), systemImage: isEditing ? "checkmark" : "pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundStyle(Color.white)
                        .background((isEditing ? draftKind : (record?.weatherType ?? draftKind)).primaryColor, in: Capsule())
                }
                .buttonStyle(.plain)

                if isEditing {
                    Button("取消") {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isEditing = false
                        }
                    }
                    .foregroundStyle(Color.weatherMuted)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 32)
        }
        .background(Color.weatherBackground)
        .onAppear {
            syncDraft(from: record)
        }
    }

    private var editBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("天气")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.weatherMuted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(WeatherKind.allCases) { kind in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                draftKind = kind
                            }
                        } label: {
                            DetailWeatherChip(kind: kind, isSelected: draftKind == kind)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text("备注")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.weatherMuted)

            TextField("给这天留一句话", text: $draftNote, axis: .vertical)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .lineLimit(2...3)
                .padding(10)
                .background(Color.weatherSurface.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.weatherLine, lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func noteText(_ note: String?) -> some View {
        if let note {
            Text("“\(note)”")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(Color.weatherInk.opacity(0.82))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.weatherSurface.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.weatherLine, lineWidth: 1)
                }
        } else {
            Text("还没有备注。")
                .font(.footnote)
                .foregroundStyle(Color.weatherMuted)
        }
    }

    private func syncDraft(from record: WeatherRecord?) {
        draftKind = record?.weatherType ?? .sunny
        draftNote = record?.displayNote ?? ""
    }
}

private struct DetailWeatherChip: View {
    let kind: WeatherKind
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: kind.symbolName)
                .font(.caption.weight(.semibold))

            Text(kind.name)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(isSelected ? Color.white : Color.weatherInk)
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background {
            Capsule()
                .fill(isSelected ? kind.primaryColor : Color.weatherSurface.opacity(0.82))
        }
        .overlay {
            Capsule()
                .stroke(isSelected ? Color.white.opacity(0.35) : Color.weatherLine, lineWidth: 1)
        }
    }
}
