import SwiftUI
import Observation

@Observable
final class DangleModel {

    struct Point {
        var position: CGPoint
        var previousPosition: CGPoint
    }

    // Number of points in the thread.
    // Point 0 is permanently attached to the menu bar.
    private(set) var points: [Point] = []

    private let pointCount = 16
    private let segmentLength: CGFloat = 8

    private var timer: Timer?
    private var impulse: CGFloat = 0

    init() {
        reset()
        startSimulation()
    }

    deinit {
        timer?.invalidate()
    }

    func reset() {

        points = (0..<pointCount).map { index in

            let position = CGPoint(
                x: 90,
                y: CGFloat(index) * segmentLength
            )

            return Point(
                position: position,
                previousPosition: position
            )
        }
    }

    // MARK: - Interaction

    func kick(strength: CGFloat = 3) {

        impulse += strength
    }

    // MARK: - Simulation

    private func startSimulation() {

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 60.0,
            repeats: true
        ) { [weak self] _ in

            self?.update()
        }
    }

    private func update() {

        guard points.count == pointCount else {
            return
        }

        var updated = points

        // -----------------------------------------
        // 1. Verlet integration
        // -----------------------------------------

        for index in 1..<updated.count {

            let current = updated[index].position
            let previous = updated[index].previousPosition

            var velocity = CGPoint(
                x: current.x - previous.x,
                y: current.y - previous.y
            )

            // Air resistance
            velocity.x *= 0.785
            velocity.y *= 0.785

            // Gravity
            velocity.y += 0.38

            updated[index].previousPosition = current

            updated[index].position = CGPoint(
                x: current.x + velocity.x,
                y: current.y + velocity.y
            )
        }

        // -----------------------------------------
        // 2. Apply mouse/click impulse
        // -----------------------------------------

        if abs(impulse) > 0.01 {

            for index in 1..<updated.count {

                let influence =
                    1.0 -
                    CGFloat(index) /
                    CGFloat(updated.count)

                updated[index].position.x +=
                    impulse * influence
            }

            impulse *= 0.82
        }

        // -----------------------------------------
        // 3. Maintain rope length
        // -----------------------------------------

        for _ in 0..<5 {

            // Anchor is fixed.
            updated[0].position = CGPoint(
                x: 90,
                y: 0
            )

            for index in 1..<updated.count {

                let previous =
                    updated[index - 1].position

                let current =
                    updated[index].position

                let dx =
                    current.x - previous.x

                let dy =
                    current.y - previous.y

                let distance =
                    max(
                        sqrt(dx * dx + dy * dy),
                        0.001
                    )

                let difference =
                    (distance - segmentLength)
                    / distance

                updated[index].position.x -=
                    dx * difference

                updated[index].position.y -=
                    dy * difference
            }
        }

        points = updated
    }
}
