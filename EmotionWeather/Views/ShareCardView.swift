import SwiftUI
import UIKit

struct ShareCardView: View {
    let record: WeatherRecord

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.weatherSurface,
                    record.weatherType.backgroundColors.first?.opacity(0.86) ?? Color.weatherBackground,
                    record.weatherType.primaryColor.opacity(0.20),
                    Color.weatherBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [record.weatherType.primaryColor.opacity(0.24), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 420
                    )
                )
                .frame(width: 760, height: 760)
                .offset(x: 240, y: -360)

            VStack(spacing: 36) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(record.date.replacingOccurrences(of: "-", with: "."))
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.weatherMuted)

                        Text("今天的我")
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(Color.weatherInk.opacity(0.72))
                    }

                    Spacer()

                    Text("天气瓶")
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.weatherInk)
                }
                .padding(.top, 88)

                WeatherBottleView(
                    kind: record.weatherType,
                    isSealed: true,
                    sealedDate: record.date.replacingOccurrences(of: "-", with: ".")
                )
                .frame(width: 380, height: 646)
                .padding(.top, 10)

                VStack(spacing: 20) {
                    Label(record.weatherName, systemImage: record.weatherType.symbolName)
                        .font(.system(size: 54, weight: .semibold, design: .serif))
                        .foregroundStyle(record.weatherType.primaryColor)

                    Text(record.quote)
                        .font(.system(size: 38, weight: .regular, design: .serif))
                        .lineSpacing(10)
                        .foregroundStyle(Color.weatherInk.opacity(0.82))
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)

                Text("今天的天气，已经被好好收起来了。")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(Color.weatherMuted)
                    .padding(.bottom, 76)
            }
            .padding(.horizontal, 88)
        }
        .frame(width: 1080, height: 1440)
    }
}

struct SharePreviewSheet: View {
    let record: WeatherRecord

    @Environment(\.dismiss) private var dismiss
    @StateObject private var renderer = ShareImageRenderer()
    @State private var previewImage: UIImage?

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
                        previewCard
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                }
                .safeAreaInset(edge: .bottom) {
                    shareBar
                }
            }
            .navigationTitle("分享卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $renderer.shareItem) { item in
                ActivityView(activityItems: [item.url])
            }
            .onAppear {
                previewImage = renderer.makeImage(record: record)
            }
        }
    }

    private var shareBar: some View {
        Button {
            renderer.render(record: record)
        } label: {
            Label("分享这张卡", systemImage: "square.and.arrow.up")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(Color.white)
                .background(record.weatherType.primaryColor, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(.ultraThinMaterial)
    }

    private var previewCard: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .tint(record.weatherType.primaryColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
            .frame(maxWidth: 324)
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .background(Color.weatherSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: 26, x: 0, y: 16)
            .accessibilityLabel("今日天气分享卡预览")
    }
}

@MainActor
final class ShareImageRenderer: ObservableObject {
    @Published var shareItem: ShareImageItem?

    func render(record: WeatherRecord) {
        guard let image = makeImage(record: record),
              let data = image.pngData() else {
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("weather-bottle-\(record.id).png")

        do {
            try data.write(to: url, options: .atomic)
            shareItem = ShareImageItem(url: url)
        } catch {
            assertionFailure("Failed to write share image: \(error)")
        }
    }

    func makeImage(record: WeatherRecord) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(record: record))
        renderer.scale = 1
        return renderer.uiImage
    }
}

struct ShareImageItem: Identifiable {
    let url: URL
    var id: URL { url }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
