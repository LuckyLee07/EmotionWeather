import SwiftUI
import UIKit

struct ShareCardView: View {
    let record: WeatherRecord

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.weatherSurface,
                    record.weatherType.backgroundColors.first ?? Color.weatherBackground,
                    Color.weatherBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 44) {
                VStack(spacing: 12) {
                    Text("今天的我：\(record.weatherName)")
                        .font(.system(size: 62, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.weatherInk)

                    Text(record.quote)
                        .font(.system(size: 34, weight: .regular, design: .serif))
                        .foregroundStyle(Color.weatherInk.opacity(0.82))
                }
                .multilineTextAlignment(.center)

                WeatherBottleView(
                    kind: record.weatherType,
                    isSealed: true,
                    sealedDate: record.date.replacingOccurrences(of: "-", with: ".")
                )
                    .frame(width: 330, height: 560)

                VStack(spacing: 12) {
                    Text(record.date.replacingOccurrences(of: "-", with: "."))
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.weatherMuted)

                    Text("天气瓶")
                        .font(.system(size: 26, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.weatherInk)
                }
            }
            .padding(.horizontal, 92)
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
