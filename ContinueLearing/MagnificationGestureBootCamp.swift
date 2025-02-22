import SwiftUI

struct MagnificationGestureBootCamp: View {
    @GestureState private var currentScale: CGFloat = 1.0
    @GestureState private var currentOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Circle().frame(width: 35, height: 35)
                Text("alisina.haidari_")
                Spacer()
                Image(systemName: "ellipsis")
            }
            .padding(.horizontal)

            // Image with Gestures
            Image("steve-jobs") // Replace with your image name
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .scaleEffect(lastScale * currentScale)
//                .offset(lastOffset + currentOffset)
                .gesture(
                    MagnificationGesture()
                        .updating($currentScale) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            lastScale *= value
                            resetToOriginalState() // Reset after gesture ends
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .updating($currentOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
//                            lastOffset += value.translation
                            resetToOriginalState() // Reset after gesture ends
                        }
                )

            // Footer
            HStack {
                Image(systemName: "heart.fill")
                Image(systemName: "text.bubble.fill")
                Spacer()
            }
            .padding(.horizontal)
            .font(.headline)

            Text("This is the caption for my photo!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
    }

    // Reset to original size and position
    private func resetToOriginalState() {
        withAnimation(.spring()) {
            lastScale = 1.0
            lastOffset = .zero
        }
    }
}

#Preview {
    MagnificationGestureBootCamp()
}
