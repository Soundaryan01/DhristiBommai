import SwiftUI

struct BeadView: View {

    let width: CGFloat

    var body: some View {
        Image("DrishtiBeads")
            .resizable()
            .scaledToFit()
            .frame(
                width: width
            )
    }
}
