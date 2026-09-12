import SwiftUI

struct ThreadView: View {

    let points: [DangleModel.Point]

    var body: some View {

        Canvas { context, size in

            guard points.count > 1 else {
                return
            }

            var path = Path()

            path.move(
                to: points[0].position
            )

            for index in 1..<points.count {

                let point =
                    points[index].position

                path.addLine(
                    to: point
                )
            }

            context.stroke(
                path,
                with: .color(
                    .black.opacity(0.75)
                ),
                style: StrokeStyle(
                    lineWidth: 1.4,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}
