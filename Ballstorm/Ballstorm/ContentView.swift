import SwiftUI

struct ContentView: View {
    @State private var showGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer()

                Text("Ballstorm")
                    .font(.system(size: 44, weight: .heavy))

                Text("Shoot the rolling balls.\nStay alive, score high.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    showGame = true
                } label: {
                    Text("Play")
                        .font(.headline)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Spacer(minLength: 24)
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar) 
        }
        .fullScreenCover(isPresented: $showGame) {
            GameContainerView()
        }
    }
}

