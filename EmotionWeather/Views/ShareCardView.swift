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

@MainActor
final class ShareImageRenderer: ObservableObject {
    @Published var shareItem: ShareImageItem?

    func render(record: WeatherRecord) {
        let renderer = ImageRenderer(content: ShareCardView(record: record))
        renderer.scale = 1

        guard let image = renderer.uiImage,
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
