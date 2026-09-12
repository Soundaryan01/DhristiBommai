import SwiftUI

struct FaceView: View {

    let size: CGFloat

    var body: some View {
        Image("DrishtiFace")
            .resizable()
            .scaledToFit()
            .frame(
                width: size,
                height: size
            )
    }
}
