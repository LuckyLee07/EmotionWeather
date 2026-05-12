import SwiftUI

struct WeatherBottleView: View {
    let kind: WeatherKind?
    var isSealed: Bool
    var compact: Bool = false
    var sealedDate: String? = nil
    var isCelebrating: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                if isCelebrating {
                    BottleShape()
                        .stroke((kind?.primaryColor ?? .weatherInk).opacity(0.34), lineWidth: compact ? 2 : 5)
                        .blur(radius: compact ? 4 : 12)
                        .scaleEffect(1.06)
                        .transition(.opacity)
                }

                WeatherEffectView(kind: kind)
                    .clipShape(BottleShape())
                    .overlay {
                        BottleShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)
                    }

                lowerGlass(width: width, height: height)

                BottleShape()
                    .stroke(Color.white.opacity(0.72), lineWidth: compact ? 1.4 : 2)

                BottleShape()
                    .stroke(Color.weatherInk.opacity(0.12), lineWidth: compact ? 0.8 : 1.2)

                highlight(width: width, height: height)

                if kind == nil {
                    emptyBottleGlint(width: width, height: height)
                }

                if isSealed {
                    cork(width: width, height: height)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if isSealed, let sealedDate, !compact {
                    dateSeal(sealedDate, width: width)
                        .offset(y: height * 0.31)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .shadow(color: (kind?.primaryColor ?? .weatherInk).opacity(compact ? 0.10 : 0.20), radius: compact ? 7 : 18, x: 0, y: compact ? 5 : 14)
        }
        .aspectRatio(0.58, contentMode: .fit)
        .accessibilityLabel(kind.map { "\($0.name)天气瓶" } ?? "空天气瓶")
    }

    private func highlight(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.38))
            .frame(width: max(2, width * 0.045), height: height * 0.46)
            .rotationEffect(.degrees(7))
            .offset(x: -width * 0.17, y: height * 0.09)
            .blur(radius: compact ? 0.5 : 1.2)
    }

    private func lowerGlass(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Spacer()
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(compact ? 0.16 : 0.24),
                            Color.weatherInk.opacity(0.035)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.58, height: height * 0.07)
                .offset(y: -height * 0.065)
        }
        .clipShape(BottleShape())
    }

    private func emptyBottleGlint(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: width * 0.10, height: width * 0.10)
                .offset(x: width * 0.16, y: -height * 0.18)

            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: width * 0.34, height: max(2, height * 0.018))
                .rotationEffect(.degrees(-8))
                .offset(x: width * 0.10, y: height * 0.28)
        }
        .blur(radius: compact ? 1 : 2)
        .clipShape(BottleShape())
    }

    private func cork(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: width * 0.045, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0xB98B5A), Color(hex: 0x7E5735)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width * 0.28, height: height * 0.12)
            .overlay {
                RoundedRectangle(cornerRadius: width * 0.045, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            }
            .offset(y: -height * 0.43)
    }

    private func dateSeal(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: max(8, min(12, width * 0.07)), weight: .medium, design: .rounded))
            .foregroundStyle(Color.weatherInk.opacity(0.58))
            .padding(.horizontal, max(7, width * 0.055))
            .padding(.vertical, max(3, width * 0.025))
            .background(Color.white.opacity(0.42), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.36), lineWidth: 1)
            }
    }
}
