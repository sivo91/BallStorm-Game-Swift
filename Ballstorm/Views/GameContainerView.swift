import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @Environment(\.dismiss) private var dismiss

    private var scene: SKScene {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .black
        return s
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(16)
            }
        }
        .interactiveDismissDisabled(true) 
    }
}
