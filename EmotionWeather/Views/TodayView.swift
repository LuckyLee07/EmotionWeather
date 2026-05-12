import SwiftUI
import UIKit

struct TodayView: View {
    @EnvironmentObject private var store: WeatherStore
    @State private var selectedKind: WeatherKind?
    @State private var draftNote = ""
    @State private var showSavedMessage = false
    @State private var isSealing = false
    @State private var sharePreviewRecord: WeatherRecord?

    var activeKind: WeatherKind? {
        selectedKind ?? store.todayRecord?.weatherType
    }

    var hasTodayRecord: Bool {
        store.todayRecord != nil
    }

    var isPreviewingSavedRecord: Bool {
        guard let todayRecord = store.todayRecord else { return false }
        return selectedKind == todayRecord.weatherType
    }

    var shouldShowSealedBottle: Bool {
        isPreviewingSavedRecord || isSealing
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 13) {
                        header

                        WeatherBottleView(
                            kind: activeKind,
                            isSealed: shouldShowSealedBottle,
                            sealedDate: shouldShowSealedBottle ? store.displayDate(Date()) : nil,
                            isCelebrating: isSealing
                        )
                            .frame(maxWidth: 150)
                            .frame(height: 258)
                            .padding(.top, 4)
                            .scaleEffect(isSealing ? 1.035 : 1)
                            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: activeKind)
                            .animation(.spring(response: 0.6, dampingFraction: 0.72), value: hasTodayRecord)
                            .animation(.spring(response: 0.42, dampingFraction: 0.58), value: isSealing)

                        quoteBlock

                        weatherPicker

                        noteEditor

                        actionButtons
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 136)
                }

                if showSavedMessage {
                    savedMessage
                }
            }
            .navigationTitle("天气瓶")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                syncTodayRecord()
            }
            .onChange(of: store.todayRecord) { _, _ in
                syncTodayRecord()
            }
            .sheet(item: $sharePreviewRecord) { record in
                SharePreviewSheet(record: record)
                    .presentationDetents([.large])
            }
        }
    }

    @ViewBuilder
    private var noteEditor: some View {
        if activeKind != nil || hasTodayRecord {
            VStack(alignment: .leading, spacing: 7) {
                Label("一句话备注", systemImage: "pencil.line")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.weatherMuted)

                TextField("给今天留一句话", text: $draftNote, axis: .vertical)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .lineLimit(1...2)
                    .foregroundStyle(Color.weatherInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.weatherSurface.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.weatherLine, lineWidth: 1)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.weatherBackground, Color(hex: 0xEEF3F2), Color.weatherSurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
            VStack(spacing: 7) {
                Text("今天的你，是什么天气？")
                .font(.system(size: 23, weight: .semibold, design: .serif))
                .foregroundStyle(Color.weatherInk)

            Text(formattedToday)
                .font(.footnote)
                .foregroundStyle(Color.weatherMuted)
        }
    }

    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }

    @ViewBuilder
    private var quoteBlock: some View {
        if let activeKind {
            VStack(spacing: 6) {
                Label(activeKind.name, systemImage: activeKind.symbolName)
                    .font(.headline)
                    .foregroundStyle(activeKind.primaryColor)

                Text(activeKind.quote)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.weatherInk)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        } else {
            Text("选择一种天气，把今天收进瓶子里。")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(Color.weatherMuted)
                .padding(.vertical, 8)
        }
    }

    private var weatherPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WeatherKind.allCases) { kind in
                    WeatherOptionButton(
                        kind: kind,
                        isSelected: activeKind == kind
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            selectedKind = kind
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                sealToday()
            } label: {
                Label(primaryButtonTitle, systemImage: primaryButtonIcon)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundStyle(activeKind == nil ? Color.weatherMuted : Color.white)
                    .background {
                        Capsule()
                            .fill(activeKind?.primaryColor ?? Color.weatherLine)
                    }
            }
            .buttonStyle(.plain)
            .opacity(activeKind == nil ? 0.82 : 1)
            .disabled(activeKind == nil)

            Button {
                shareToday()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 56, height: 54)
                    .foregroundStyle(store.todayRecord == nil ? Color.weatherMuted : Color.weatherInk)
                    .background(Color.weatherSurface.opacity(0.82), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.weatherLine, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .opacity(store.todayRecord == nil ? 0.72 : 1)
            .disabled(store.todayRecord == nil)
            .accessibilityLabel("预览分享卡")
        }
    }

    private var savedMessage: some View {
        VStack {
            Spacer()

            HStack(spacing: 14) {
                WeatherBottleView(
                    kind: activeKind,
                    isSealed: true,
                    compact: true,
                    sealedDate: nil
                )
                .frame(width: 34, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text("已放入本周瓶架")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.weatherInk)

                    Text("今天的天气，已经被好好收起来了。")
                        .font(.caption)
                        .foregroundStyle(Color.weatherMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "tray.full")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(activeKind?.primaryColor ?? Color.weatherInk)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                Capsule()
                    .fill(activeKind?.primaryColor.opacity(0.28) ?? Color.weatherLine)
                    .frame(width: 74, height: 4)
                    .offset(x: 16, y: -7)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.94, anchor: .bottom)))
    }

    private var primaryButtonTitle: String {
        guard hasTodayRecord else { return "封存今天" }
        return isPreviewingSavedRecord ? "重新感受今天" : "封存新的感受"
    }

    private var primaryButtonIcon: String {
        guard hasTodayRecord else { return "lock.fill" }
        return isPreviewingSavedRecord ? "arrow.triangle.2.circlepath" : "lock.fill"
    }

    private func sealToday() {
        guard let activeKind else { return }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
            store.save(activeKind, note: draftNote, replacesNote: true)
            selectedKind = activeKind
            showSavedMessage = true
            isSealing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.easeOut(duration: 0.32)) {
                isSealing = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.25)) {
                showSavedMessage = false
            }
        }
    }

    private func shareToday() {
        guard let record = store.todayRecord else { return }
        sharePreviewRecord = record
    }

    private func syncTodayRecord() {
        selectedKind = store.todayRecord?.weatherType
        draftNote = store.todayRecord?.displayNote ?? ""
    }
}

private struct WeatherOptionButton: View {
    let kind: WeatherKind
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: kind.symbolName)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 24, height: 24)

                Text(kind.name)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(isSelected ? Color.white : Color.weatherInk)
            .frame(width: 60, height: 62)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? kind.primaryColor : Color.weatherSurface.opacity(0.78))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.42) : Color.weatherLine, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint(kind.emotionHint)
    }
}
