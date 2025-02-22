import SwiftUI
import ARKit

struct ContentView: View {
    @State private var instruction: String = "Please position your face in the frame."
    @State private var isFaceDetected: Bool = false
    @State private var isHeadTurnedRight: Bool = false
    @State private var isHeadTurnedLeft: Bool = false
    @State private var isBlinking: Bool = false
    @State private var isFaceVerified: Bool = false
    @State private var isAccessoryDetected: Bool = false
    @State private var currentStep: Int = 0 // Track the current step in the flow

    var body: some View {
        ZStack {
            // ARKit Camera View in the Background
            ARKitView(
                isFaceDetected: $isFaceDetected,
                isHeadTurnedRight: $isHeadTurnedRight,
                isHeadTurnedLeft: $isHeadTurnedLeft,
                isBlinking: $isBlinking,
                isFaceVerified: $isFaceVerified,
                isAccessoryDetected: $isAccessoryDetected,
                currentStep: $currentStep
            )
            .edgesIgnoringSafeArea(.all)

            // Black background with opacity outside the circle
            Color.black.opacity(0.5)
                .mask(
                    Circle()
                        .frame(width: 300, height: 300) // Size of the circle
                        .blendMode(.destinationOut) // Clear the inside of the circle
                )
                .compositingGroup() // Apply the mask

            // Circle Frame at the Center
            Ellipse()
                .stroke(Color.white, lineWidth: 4) // White outline
                .frame(width: 300, height: 350) // Size 

            // Overlay for Instructions
            VStack {
                Spacer()
                Text(instruction)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
        .onChange(of: isFaceDetected) { detected in
            if detected && currentStep == 0 {
                currentStep = 1 // Move to the next step
                instruction = "Please turn your head to the left."
            }
        }
        .onChange(of: isHeadTurnedLeft) { turnedLeft in
            if turnedLeft && currentStep == 1 {
                currentStep = 2 // Move to the next step
                instruction = "Please turn your head to the right."
            }
        }
        .onChange(of: isHeadTurnedRight) { turnedRight in
            if turnedRight && currentStep == 2 {
                currentStep = 3 // Move to the next step
                instruction = "Please blink your eyes."
            }
        }
        .onChange(of: isBlinking) { blinking in
            if blinking && currentStep == 3 {
                currentStep = 4 // Move to the next step
                instruction = "Verifying face..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if !isAccessoryDetected {
                        isFaceVerified = true
                        print("true") // Print true to the console
                    }
                }
            }
        }
        .onChange(of: isAccessoryDetected) { accessoryDetected in
            if accessoryDetected {
                instruction = "Please remove any accessories (mask, glasses, hat)."
            }
            .padding()
        }
    }
}

struct ARKitView: UIViewRepresentable {
    @Binding var isFaceDetected: Bool
    @Binding var isHeadTurnedRight: Bool
    @Binding var isHeadTurnedLeft: Bool
    @Binding var isBlinking: Bool
    @Binding var isFaceVerified: Bool
    @Binding var isAccessoryDetected: Bool
    @Binding var currentStep: Int
    @Binding var capturedImage: UIImage?
    @Binding var showImagePreview: Bool

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        let configuration = ARFaceTrackingConfiguration()
        arView.session.delegate = context.coordinator
        
        // Disable unnecessary logging
        arView.showsStatistics = false
        arView.debugOptions = []
        
        arView.session.run(configuration)
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARKitView
        var arView: ARSCNView?

        init(parent: ARKitView) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.first as? ARFaceAnchor else {
                Task { @MainActor in
                    parent.isFaceDetected = false
                }
                return
            }

            Task { @MainActor in
                parent.isFaceDetected = true

                // Calculate head orientation (yaw, pitch, roll)
                let transform = faceAnchor.transform
                let rotation = simd_quatf(transform)
                let eulerAngles = rotation.eulerAngles

                // Check head orientation (yaw for left/right)
                if parent.currentStep == 1 && eulerAngles.y < -0.2 { // Turn left
                    parent.isHeadTurnedLeft = true
                } else if parent.currentStep == 2 && eulerAngles.y > 0.2 { // Turn right
                    parent.isHeadTurnedRight = true
                }

                // Check for blinking
                let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
                let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
                if leftEyeBlink > 0.5 || rightEyeBlink > 0.5 {
                    parent.isBlinking = true

                    // Capture the image when the user blinks
                    if let arView = self.arView {
                        parent.capturedImage = arView.snapshot()
                        parent.showImagePreview = true
                    }
                } else {
                    parent.isBlinking = false
                }
            }
        }
    }
}

// Extension to convert quaternion to Euler angles
extension simd_quatf {
    var eulerAngles: SIMD3<Float> {
        let sinr_cosp = 2 * (self.real * self.imag.x + self.imag.y * self.imag.z)
        let cosr_cosp = 1 - 2 * (self.imag.x * self.imag.x + self.imag.y * self.imag.y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        let sinp = 2 * (self.real * self.imag.y - self.imag.z * self.imag.x)
        let pitch = abs(sinp) >= 1 ? copysign(Float.pi / 2, sinp) : asin(sinp)

        let siny_cosp = 2 * (self.real * self.imag.z + self.imag.x * self.imag.y)
        let cosy_cosp = 1 - 2 * (self.imag.y * self.imag.y + self.imag.z * self.imag.z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        return SIMD3<Float>(roll, pitch, yaw)
    }
}
