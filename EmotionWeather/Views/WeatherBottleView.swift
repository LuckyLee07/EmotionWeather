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

                if isSealed {
                    cork(width: width, height: height)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                BottleShape()
                    .stroke(Color.white.opacity(0.72), lineWidth: compact ? 1.4 : 2)

                BottleShape()
                    .stroke(Color.weatherInk.opacity(0.12), lineWidth: compact ? 0.8 : 1.2)

                if isSealed {
                    bottleMouthRim(width: width, height: height)
                }

                highlight(width: width, height: height)

                if kind == nil {
                    emptyBottleGlint(width: width, height: height)
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
        let capWidth = width * 0.265
        let capHeight = height * 0.104

        return ZStack {
            CorkStopperShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xD9C19A).opacity(0.98),
                            Color(hex: 0xB98F63).opacity(0.95),
                            Color(hex: 0x8F6D4B).opacity(0.90)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            CorkStopperShape()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.24), Color.white.opacity(0.04), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xE4D0AC).opacity(0.98),
                            Color(hex: 0xBD966C).opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: capWidth * 0.94, height: capHeight * 0.30)
                .offset(y: -capHeight * 0.39)

            Ellipse()
                .stroke(Color.white.opacity(compact ? 0.18 : 0.28), lineWidth: compact ? 0.6 : 1)
                .frame(width: capWidth * 0.94, height: capHeight * 0.30)
                .offset(y: -capHeight * 0.39)

            ForEach(CorkSpeck.allCases) { speck in
                Circle()
                    .fill(speck.color)
                    .frame(width: max(1, capWidth * speck.size), height: max(1, capWidth * speck.size))
                    .offset(x: capWidth * speck.x, y: capHeight * speck.y)
            }
            .opacity(compact ? 0.32 : 0.46)

            Capsule()
                .fill(Color.weatherInk.opacity(0.10))
                .frame(width: capWidth * 0.70, height: max(1, capHeight * 0.075))
                .offset(y: capHeight * 0.40)

            CorkStopperShape()
                .stroke(Color.white.opacity(compact ? 0.16 : 0.24), lineWidth: compact ? 0.7 : 1)
        }
        .frame(width: capWidth, height: capHeight)
        .shadow(color: Color.weatherInk.opacity(0.08), radius: compact ? 2 : 5, x: 0, y: compact ? 1 : 3)
        .offset(y: -height * 0.438)
    }

    private func bottleMouthRim(width: CGFloat, height: CGFloat) -> some View {
        let rimWidth = width * 0.35
        let rimHeight = max(3, height * 0.024)
        let corner = width * 0.028

        return ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.34), Color.white.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: rimWidth, height: rimHeight)

            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Color.white.opacity(0.50), lineWidth: compact ? 0.8 : 1.2)
                .frame(width: rimWidth, height: rimHeight)

            Capsule()
                .fill(Color.weatherInk.opacity(0.08))
                .frame(width: rimWidth * 0.72, height: max(1, rimHeight * 0.22))
                .offset(y: rimHeight * 0.36)
        }
        .offset(y: -height * 0.392)
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

private struct CorkStopperShape: Shape {
    func path(in rect: CGRect) -> Path {
        let topY = rect.minY + rect.height * 0.14
        let bottomY = rect.maxY - rect.height * 0.05
        let topHalfWidth = rect.width * 0.47
        let bottomHalfWidth = rect.width * 0.38
        let centerX = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: centerX - topHalfWidth, y: topY))
        path.addQuadCurve(
            to: CGPoint(x: centerX + topHalfWidth, y: topY),
            control: CGPoint(x: centerX, y: rect.minY + rect.height * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: centerX + bottomHalfWidth, y: bottomY),
            control1: CGPoint(x: centerX + topHalfWidth * 0.98, y: rect.minY + rect.height * 0.34),
            control2: CGPoint(x: centerX + bottomHalfWidth * 1.02, y: rect.minY + rect.height * 0.70)
        )
        path.addQuadCurve(
            to: CGPoint(x: centerX - bottomHalfWidth, y: bottomY),
            control: CGPoint(x: centerX, y: rect.maxY + rect.height * 0.03)
        )
        path.addCurve(
            to: CGPoint(x: centerX - topHalfWidth, y: topY),
            control1: CGPoint(x: centerX - bottomHalfWidth * 1.02, y: rect.minY + rect.height * 0.70),
            control2: CGPoint(x: centerX - topHalfWidth * 0.98, y: rect.minY + rect.height * 0.34)
        )
        path.closeSubpath()
        return path
    }
}

private enum CorkSpeck: CaseIterable, Identifiable {
    case a, b, c, d, e, f, g, h, i, j, k, l

    var id: Self { self }

    var x: CGFloat {
        switch self {
        case .a: -0.30
        case .b: -0.18
        case .c: -0.05
        case .d: 0.18
        case .e: 0.31
        case .f: -0.34
        case .g: -0.11
        case .h: 0.08
        case .i: 0.26
        case .j: -0.22
        case .k: 0.02
        case .l: 0.21
        }
    }

    var y: CGFloat {
        switch self {
        case .a: -0.32
        case .b: -0.43
        case .c: -0.27
        case .d: -0.38
        case .e: -0.20
        case .f: -0.03
        case .g: 0.06
        case .h: -0.08
        case .i: 0.08
        case .j: 0.26
        case .k: 0.31
        case .l: 0.22
        }
    }

    var size: CGFloat {
        switch self {
        case .a, .h, .l: 0.020
        case .b, .e, .j: 0.014
        case .c, .g, .i: 0.017
        case .d, .f, .k: 0.011
        }
    }

    var color: Color {
        switch self {
        case .b, .d, .f, .j:
            Color.weatherInk.opacity(0.18)
        case .c, .h, .k:
            Color.white.opacity(0.20)
        default:
            Color(hex: 0x7E5C3E).opacity(0.22)
        }
    }
}
