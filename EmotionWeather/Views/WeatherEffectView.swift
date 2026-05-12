import SwiftUI

struct WeatherEffectView: View {
    let kind: WeatherKind?

    var body: some View {
        ZStack {
            if let kind {
                LinearGradient(
                    colors: kind.backgroundColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                ambientLayer(for: kind)
                particles(for: kind)
            } else {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.48),
                        Color(hex: 0xEDE8DF).opacity(0.26),
                        Color.white.opacity(0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    @ViewBuilder
    private func ambientLayer(for kind: WeatherKind) -> some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                switch kind {
                case .sunny:
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.72), Color(hex: 0xF7C957).opacity(0.12), .clear],
                                center: .center,
                                startRadius: 4,
                                endRadius: size.width * 0.46
                            )
                        )
                        .frame(width: size.width * 0.72, height: size.width * 0.72)
                        .offset(y: -size.height * 0.22)

                case .fog:
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(Color.white.opacity(0.20))
                            .frame(width: size.width * (0.72 + CGFloat(index) * 0.11), height: size.height * 0.09)
                            .blur(radius: 9)
                            .offset(x: index.isMultiple(of: 2) ? -size.width * 0.12 : size.width * 0.10, y: -size.height * 0.18 + CGFloat(index) * size.height * 0.14)
                    }

                case .rain:
                    VStack {
                        Spacer()
                        ZStack(alignment: .top) {
                            Rectangle()
                                .fill(Color(hex: 0x477C97).opacity(0.20))
                                .frame(height: size.height * 0.28)

                            Ellipse()
                                .fill(Color.white.opacity(0.20))
                                .frame(width: size.width * 0.74, height: size.height * 0.10)
                                .offset(y: -size.height * 0.045)
                        }
                    }

                case .thunder:
                    RadialGradient(
                        colors: [.clear, Color(hex: 0x161827).opacity(0.58)],
                        center: .center,
                        startRadius: size.width * 0.16,
                        endRadius: size.height * 0.62
                    )

                    ForEach(0..<3, id: \.self) { index in
                        Ellipse()
                            .fill(Color(hex: 0x1F2035).opacity(0.40))
                            .frame(width: size.width * (0.70 - CGFloat(index) * 0.08), height: size.height * 0.18)
                            .blur(radius: 8)
                            .offset(x: CGFloat(index - 1) * size.width * 0.16, y: -size.height * 0.20 + CGFloat(index) * size.height * 0.03)
                    }

                case .snow:
                    VStack {
                        LinearGradient(
                            colors: [Color.white.opacity(0.52), Color.white.opacity(0.05), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: size.height * 0.32)
                        Spacer()
                    }

                case .wind:
                    ForEach(0..<5, id: \.self) { index in
                        Capsule()
                            .fill(Color.white.opacity(0.20))
                            .frame(width: size.width * (0.56 + CGFloat(index) * 0.07), height: 3)
                            .rotationEffect(.degrees(index.isMultiple(of: 2) ? -12 : 10))
                            .offset(x: CGFloat(index - 2) * size.width * 0.05, y: -size.height * 0.22 + CGFloat(index) * size.height * 0.13)
                            .blur(radius: 1.2)
                    }

                case .sunset:
                    VStack {
                        Spacer()
                        LinearGradient(
                            colors: [Color(hex: 0xA76688).opacity(0.08), Color(hex: 0x8C5B7E).opacity(0.34)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: size.height * 0.38)
                    }

                    Circle()
                        .fill(Color(hex: 0xFFE0A2).opacity(0.34))
                        .frame(width: size.width * 0.48, height: size.width * 0.48)
                        .offset(y: size.height * 0.18)

                case .moon:
                    RadialGradient(
                        colors: [Color(hex: 0xF5EAC8).opacity(0.12), .clear],
                        center: UnitPoint(x: 0.66, y: 0.22),
                        startRadius: 4,
                        endRadius: size.width * 0.58
                    )

                    LinearGradient(
                        colors: [Color(hex: 0x0E172C).opacity(0.38), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func particles(for kind: WeatherKind) -> some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                switch kind {
                case .sunny:
                    drawSun(time: time, context: context, size: size)
                case .fog:
                    drawFog(time: time, context: context, size: size)
                case .rain:
                    drawRain(time: time, context: context, size: size)
                case .thunder:
                    drawThunder(time: time, context: context, size: size)
                case .snow:
                    drawSnow(time: time, context: context, size: size)
                case .wind:
                    drawWind(time: time, context: context, size: size)
                case .sunset:
                    drawSunset(time: time, context: context, size: size)
                case .moon:
                    drawMoon(time: time, context: context, size: size)
                }
            }
        }
    }

    private func drawSun(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.34)
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 24, y: center.y - 24, width: 48, height: 48)),
            with: .color(Color(hex: 0xFFE59B).opacity(0.72))
        )

        for index in 0..<22 {
            let phase = Double(index) * 0.73
            let x = size.width * (0.12 + 0.76 * fraction(sin(phase) * 13.17))
            let drift = sin(time * 0.35 + phase) * 8
            let y = size.height * (0.18 + 0.62 * fraction(cos(phase) * 7.91)) + drift
            let radius = 1.8 + fraction(sin(phase * 1.7)) * 3.2
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color(Color.white.opacity(0.55))
            )
        }
    }

    private func drawFog(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        for index in 0..<7 {
            let y = size.height * (0.20 + Double(index) * 0.09)
            let xOffset = sin(time * 0.18 + Double(index)) * size.width * 0.08
            let rect = CGRect(
                x: -size.width * 0.16 + xOffset,
                y: y,
                width: size.width * 1.32,
                height: size.height * 0.12
            )
            context.fill(
                Path(roundedRect: rect, cornerRadius: rect.height / 2),
                with: .color(Color.white.opacity(0.23))
            )
        }
    }

    private func drawRain(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        for index in 0..<34 {
            let seed = Double(index)
            let x = size.width * (0.08 + 0.84 * fraction(seed * 0.318))
            let speed = 0.34 + fraction(seed * 0.211) * 0.42
            let y = size.height * fraction(time * speed + seed * 0.137)
            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x - 3, y: y + 14))
            context.stroke(path, with: .color(Color.white.opacity(0.58)), lineWidth: 1.15)
        }

        for index in 0..<4 {
            let y = size.height * (0.72 + Double(index) * 0.045)
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.18, y: y))
            path.addCurve(
                to: CGPoint(x: size.width * 0.82, y: y + sin(time + Double(index)) * 4),
                control1: CGPoint(x: size.width * 0.36, y: y + 8),
                control2: CGPoint(x: size.width * 0.62, y: y - 8)
            )
            context.stroke(path, with: .color(Color.white.opacity(0.18)), lineWidth: 1)
        }
    }

    private func drawThunder(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        drawFog(time: time * 0.8, context: context, size: size)

        let pulse = max(0, sin(time * 2.6))
        if pulse > 0.72 {
            var bolt = Path()
            bolt.move(to: CGPoint(x: size.width * 0.55, y: size.height * 0.22))
            bolt.addLine(to: CGPoint(x: size.width * 0.43, y: size.height * 0.47))
            bolt.addLine(to: CGPoint(x: size.width * 0.56, y: size.height * 0.44))
            bolt.addLine(to: CGPoint(x: size.width * 0.42, y: size.height * 0.72))
            context.stroke(
                bolt,
                with: .color(Color(hex: 0xFFF4A8).opacity(0.45 + pulse * 0.35)),
                lineWidth: 4
            )
        }
    }

    private func drawSnow(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        for index in 0..<28 {
            let seed = Double(index)
            let baseX = size.width * (0.10 + 0.80 * fraction(seed * 0.271))
            let x = baseX + sin(time * 0.35 + seed) * 8
            let y = size.height * fraction(time * (0.055 + fraction(seed) * 0.035) + seed * 0.119)
            let radius = 2 + fraction(seed * 0.77) * 2.4
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                with: .color(Color.white.opacity(0.78))
            )
        }
    }

    private func drawWind(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        for index in 0..<8 {
            let y = size.height * (0.18 + Double(index) * 0.08)
            let offset = sin(time * 0.6 + Double(index) * 0.7) * size.width * 0.12
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.12 + offset, y: y))
            path.addCurve(
                to: CGPoint(x: size.width * 0.88 + offset, y: y + 10),
                control1: CGPoint(x: size.width * 0.33 + offset, y: y - 18),
                control2: CGPoint(x: size.width * 0.62 + offset, y: y + 26)
            )
            context.stroke(path, with: .color(Color.white.opacity(0.35)), lineWidth: 1.4)
        }
    }

    private func drawSunset(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        let sunY = size.height * (0.50 + sin(time * 0.12) * 0.025)
        context.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.32, y: sunY, width: size.width * 0.36, height: size.width * 0.36)),
            with: .color(Color(hex: 0xFFE0A2).opacity(0.55))
        )

        for index in 0..<5 {
            let y = size.height * (0.25 + Double(index) * 0.11)
            var path = Path()
            path.move(to: CGPoint(x: size.width * 0.12, y: y))
            path.addCurve(
                to: CGPoint(x: size.width * 0.88, y: y + sin(time * 0.2 + Double(index)) * 6),
                control1: CGPoint(x: size.width * 0.32, y: y - 12),
                control2: CGPoint(x: size.width * 0.64, y: y + 12)
            )
            context.stroke(path, with: .color(Color.white.opacity(0.18)), lineWidth: 2)
        }
    }

    private func drawMoon(time: TimeInterval, context: GraphicsContext, size: CGSize) {
        let moonRect = CGRect(
            x: size.width * 0.56,
            y: size.height * 0.18,
            width: size.width * 0.20,
            height: size.width * 0.20
        )
        context.fill(Path(ellipseIn: moonRect), with: .color(Color(hex: 0xF7F0D8).opacity(0.86)))
        context.fill(
            Path(ellipseIn: moonRect.offsetBy(dx: size.width * 0.06, dy: -size.width * 0.02)),
            with: .color(Color(hex: 0x304B78).opacity(0.82))
        )

        for index in 0..<18 {
            let seed = Double(index)
            let pulse = 0.25 + 0.35 * fraction(sin(time * 0.7 + seed))
            let x = size.width * (0.14 + 0.72 * fraction(seed * 0.341))
            let y = size.height * (0.18 + 0.62 * fraction(seed * 0.197))
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: 2.2, height: 2.2)),
                with: .color(Color.white.opacity(pulse))
            )
        }
    }

    private func fraction(_ value: Double) -> Double {
        let raw = abs(sin(value * 12.9898) * 43758.5453)
        return raw - floor(raw)
    }
}
