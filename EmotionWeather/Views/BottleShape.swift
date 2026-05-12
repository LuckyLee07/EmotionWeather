import SwiftUI

struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.34
        let shoulderY = height * 0.205
        let bodyTopY = height * 0.295
        let bottomY = height * 0.96
        let sideInset = width * 0.13
        let corner = width * 0.12

        let neckLeft = rect.midX - neckWidth / 2
        let neckRight = rect.midX + neckWidth / 2
        let bodyLeft = rect.minX + sideInset
        let bodyRight = rect.maxX - sideInset

        var path = Path()
        path.move(to: CGPoint(x: neckLeft, y: rect.minY + height * 0.04))
        path.addLine(to: CGPoint(x: neckLeft, y: shoulderY))
        path.addCurve(
            to: CGPoint(x: bodyLeft, y: bodyTopY),
            control1: CGPoint(x: neckLeft, y: shoulderY + height * 0.035),
            control2: CGPoint(x: bodyLeft, y: shoulderY + height * 0.005)
        )
        path.addLine(to: CGPoint(x: bodyLeft, y: bottomY - corner))
        path.addQuadCurve(
            to: CGPoint(x: bodyLeft + corner, y: bottomY),
            control: CGPoint(x: bodyLeft, y: bottomY)
        )
        path.addLine(to: CGPoint(x: bodyRight - corner, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: bodyRight, y: bottomY - corner),
            control: CGPoint(x: bodyRight, y: bottomY)
        )
        path.addLine(to: CGPoint(x: bodyRight, y: bodyTopY))
        path.addCurve(
            to: CGPoint(x: neckRight, y: shoulderY),
            control1: CGPoint(x: bodyRight, y: shoulderY + height * 0.005),
            control2: CGPoint(x: neckRight, y: shoulderY + height * 0.035)
        )
        path.addLine(to: CGPoint(x: neckRight, y: rect.minY + height * 0.04))
        path.closeSubpath()
        return path
    }
}
