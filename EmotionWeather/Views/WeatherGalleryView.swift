import SwiftUI

struct WeatherGalleryView: View {
    @State private var isSealed = true

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.weatherBackground, Color(hex: 0xEEF3F2), Color.weatherSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header

                    Picker("瓶子状态", selection: $isSealed) {
                        Text("封存").tag(true)
                        Text("预览").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(WeatherKind.allCases) { kind in
                            WeatherGalleryCard(kind: kind, isSealed: isSealed)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("天气视觉验收")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("八种天气瓶")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(Color.weatherInk)

            Text("比较颜色、粒子、氛围和封存状态")
                .font(.subheadline)
                .foregroundStyle(Color.weatherMuted)
        }
        .padding(.horizontal, 22)
    }
}

private struct WeatherGalleryCard: View {
    let kind: WeatherKind
    let isSealed: Bool

    var body: some View {
        VStack(spacing: 10) {
            WeatherBottleView(
                kind: kind,
                isSealed: isSealed,
                sealedDate: isSealed ? "5月12日" : nil
            )
            .frame(height: 164)
            .padding(.top, 8)

            VStack(spacing: 4) {
                Label(kind.name, systemImage: kind.symbolName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(kind.primaryColor)

                Text(kind.quote)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(Color.weatherMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .frame(minHeight: 30)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(Color.weatherSurface.opacity(0.76), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(kind.primaryColor.opacity(0.20), lineWidth: 1)
        }
    }
}
