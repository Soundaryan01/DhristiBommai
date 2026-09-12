import SwiftUI

struct ContentView: View {

    let charm: Charm
    let customImagePath: URL?

    @State private var model = DangleModel()

    private let beadsWidth: CGFloat = 28
    private let faceSize: CGFloat = 115
    let canvasWidth: CGFloat = 300

    @ViewBuilder
    private var charmImage: some View {

        if let customImagePath,
           let nsImage = NSImage(
               contentsOf: customImagePath
           ) {

            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()

        } else {

            Image(charm.imageName)
                .resizable()
                .scaledToFit()
        }
    }
    
    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // --------------------------------
                // Rope
                // --------------------------------

                ThreadView(
                    points: model.points
                )


                // --------------------------------
                // Beads
                // --------------------------------

                if let bottom = model.points.last {

                    Image("DrishtiBeads")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: beadsWidth
                        )
                        .position(
                            x: bottom.position.x,
                            y: bottom.position.y + 16
                        )
                }


                // --------------------------------
                // Face
                // --------------------------------

                if let bottom = model.points.last {

                    charmImage
                        .frame(
                            width: faceSize,
                            height: faceSize
                        )
                        .position(
                            x: bottom.position.x,
                            y: bottom.position.y + 72
                        )
                        .contentShape(
                            Rectangle()
                        )
                        .onHover { hovering in

                            if hovering {

                                model.kick(
                                    strength: 3
                                )
                            }
                        }
                        .onTapGesture {

                            model.kick(
                                strength: 10
                            )
                        }
                }
            }
        }
        .frame(
            width: 250,
            height: 260
        )
    }
}
