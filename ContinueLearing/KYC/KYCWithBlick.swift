import SwiftUI
import ARKit

// MARK: - FaceRecognitionView
struct FaceRecognitionView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var processCompleted: Bool = false

    var body: some View {
        if processCompleted {
            KYCResultView(capturedImage: $capturedImage) {
                capturedImage = nil
                processCompleted = false
            }
        } else {
            KYCProcessView(capturedImage: $capturedImage) {
                processCompleted = true
            }
        }
    }
}

// MARK: - KYCProcessView
struct KYCProcessView: View {
    @Binding var capturedImage: UIImage?
    var onCompleted: () -> Void

    @State private var instruction: String = "Please position your face in the frame."
    @State private var isFaceDetected: Bool = false
    @State private var isHeadTurnedRight: Bool = false
    @State private var isHeadTurnedLeft: Bool = false
    @State private var isBlinking: Bool = false
    @State private var isFaceVerified: Bool = false
    @State private var isAccessoryDetected: Bool = false
    @State private var isFaceInsideEllipse: Bool = false
    @State private var isFaceTooFar: Bool = false
    @State private var isFaceTooClose: Bool = false
    @State private var currentStep: Int = 0  // 0: positioning, 1: left, 2: right, 3: blink, 4: verifying

    // Timer-related state
    @State private var countdown: Int = 10
    @State private var timer: Timer? = nil
    @State private var showAlert: Bool = false
    // New flag to ensure we only reset once for distance issues.
    @State private var hasResetDueToDistance: Bool = false

    var body: some View {
        ZStack {
            ARKitView(
                isFaceDetected: $isFaceDetected,
                isHeadTurnedRight: $isHeadTurnedRight,
                isHeadTurnedLeft: $isHeadTurnedLeft,
                isBlinking: $isBlinking,
                isFaceVerified: $isFaceVerified,
                isAccessoryDetected: $isAccessoryDetected,
                isFaceInsideEllipse: $isFaceInsideEllipse,
                isFaceTooFar: $isFaceTooFar,
                isFaceTooClose: $isFaceTooClose,
                currentStep: $currentStep,
                capturedImage: $capturedImage
            )
            .edgesIgnoringSafeArea(.all)

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                Ellipse()
                    .frame(width: 300, height: 350)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()

            Ellipse()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 300, height: 350)

            VStack {
                Spacer()
                if currentStep >= 1 && currentStep <= 3 {
                    Text("Time: \(countdown)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
                Text(instruction)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
            }
        }
        .background(Color.clear)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Time Out"),
                message: Text("Time out, starting again."),
                dismissButton: .default(Text("OK"), action: {
                    resetFlow()
                })
            )
        }
        .onChange(of: isFaceDetected) { detected in
            if currentStep == 0 {
                if detected {
                    instruction = isFaceInsideEllipse ? "Please turn your head to the left." : "Please position your face inside the frame."
                } else {
                    instruction = "Please position your face in the frame."
                }
            }
        }
        .onChange(of: isFaceTooFar) { tooFar in
            if tooFar && !hasResetDueToDistance {
                instruction = "You're too far. Please move closer."
                resetFlow()
                hasResetDueToDistance = true
            }
        }
        .onChange(of: isFaceTooClose) { tooClose in
            if tooClose && !hasResetDueToDistance {
                instruction = "You're too close. Please move back."
                resetFlow()
                hasResetDueToDistance = true
            }
        }
        .onChange(of: isFaceInsideEllipse) { inside in
            if !inside && currentStep > 0 {
                resetFlow()
            } else if inside && isFaceDetected && currentStep == 0 {
                currentStep = 1
                instruction = "Please turn your head to the left."
            }
        }
        .onChange(of: currentStep) { newStep in
            timer?.invalidate()
            timer = nil
            if newStep >= 1 && newStep <= 3 {
                countdown = 10
                startTimer()
            }
        }
        .onChange(of: isHeadTurnedLeft) { turnedLeft in
            if turnedLeft && currentStep == 1 {
                currentStep = 2
                instruction = "Please turn your head to the right."
            }
        }
        .onChange(of: isHeadTurnedRight) { turnedRight in
            if turnedRight && currentStep == 2 {
                currentStep = 3
                instruction = "Please blink your eyes."
            }
        }
        .onChange(of: isBlinking) { blinking in
            if blinking && currentStep == 3 {
                currentStep = 4
                instruction = "Verifying face..."
                timer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !isAccessoryDetected {
                        isFaceVerified = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onCompleted()
                        }
                    }
                }
            }
        }
        .onChange(of: isAccessoryDetected) { accessoryDetected in
            if accessoryDetected {
                instruction = "Please remove any accessories (mask, glasses, hat)."
            }
        }
        // Periodic check every 0.5 seconds to update reset flag.
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            if !isFaceTooFar && !isFaceTooClose {
                hasResetDueToDistance = false
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                timer = nil
                showAlert = true
            }
        }
    }

    private func resetFlow() {
        currentStep = 0
        isHeadTurnedLeft = false
        isHeadTurnedRight = false
        isBlinking = false
        countdown = 10
        instruction = "Please position your face inside the frame."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if isFaceInsideEllipse && isFaceDetected {
                currentStep = 1
                instruction = "Please turn your head to the left."
            }
        }
    }
}

// MARK: - KYCResultView
struct KYCResultView: View {
    @Binding var capturedImage: UIImage?
    var onRestart: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 400)
            } else {
                Text("No image captured yet.")
                    .foregroundColor(.gray)
            }
            Button(action: { onRestart() }) {
                Text(capturedImage == nil ? "Start KYC" : "Take Again")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - ARKitView
struct ARKitView: UIViewRepresentable {
    @Binding var isFaceDetected: Bool
    @Binding var isHeadTurnedRight: Bool
    @Binding var isHeadTurnedLeft: Bool
    @Binding var isBlinking: Bool
    @Binding var isFaceVerified: Bool
    @Binding var isAccessoryDetected: Bool
    @Binding var isFaceInsideEllipse: Bool
    @Binding var isFaceTooFar: Bool
    @Binding var isFaceTooClose: Bool
    @Binding var currentStep: Int
    @Binding var capturedImage: UIImage?

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        let configuration = ARFaceTrackingConfiguration()
        arView.session.delegate = context.coordinator
        arView.showsStatistics = false
        arView.debugOptions = []
        context.coordinator.arView = arView
        arView.session.run(configuration)
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARKitView
        weak var arView: ARSCNView?

        let ellipseCenter: CGPoint = CGPoint(x: UIScreen.main.bounds.midX,
                                               y: UIScreen.main.bounds.midY)
        let radiusX: CGFloat = 150
        let radiusY: CGFloat = 175
        // Distance thresholds (in meters)
        let distanceThresholdMax: Float = 0.6  // Too far if > 0.6 m.
        let distanceThresholdMin: Float = 0.2  // Too close if < 0.2 m.

        init(parent: ARKitView) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.first as? ARFaceAnchor else {
                DispatchQueue.main.async {
                    self.parent.isFaceDetected = false
                }
                return
            }
            DispatchQueue.main.async {
                self.parent.isFaceDetected = true

                if let view = self.arView {
                    let facePosition = simd_make_float3(faceAnchor.transform.columns.3)
                    let distance = abs(facePosition.z)
                    self.parent.isFaceTooFar = distance > self.distanceThresholdMax
                    self.parent.isFaceTooClose = distance < self.distanceThresholdMin

                    let facePositionSCN = SCNVector3(facePosition.x, facePosition.y, facePosition.z)
                    let projectedPoint = view.projectPoint(facePositionSCN)
                    let facePoint = CGPoint(x: CGFloat(projectedPoint.x), y: CGFloat(projectedPoint.y))
                    let dx = facePoint.x - self.ellipseCenter.x
                    let dy = facePoint.y - self.ellipseCenter.y
                    let ellipseEquation = (dx * dx) / (self.radiusX * self.radiusX) + (dy * dy) / (self.radiusY * self.radiusY)
                    self.parent.isFaceInsideEllipse = ellipseEquation <= 1.0
                }

                guard self.parent.isFaceInsideEllipse else { return }

                let transform = faceAnchor.transform
                let rotation = simd_quatf(transform)
                let eulerAngles = rotation.eulerAngles

                if self.parent.currentStep == 1 && eulerAngles.y < -0.2 {
                    self.parent.isHeadTurnedLeft = true
                } else if self.parent.currentStep == 2 && eulerAngles.y > 0.2 {
                    self.parent.isHeadTurnedRight = true
                }

                let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
                let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
                self.parent.isBlinking = (leftEyeBlink > 0.5 || rightEyeBlink > 0.5)

                if self.parent.currentStep == 4 && self.parent.isFaceVerified == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let view = self.arView {
                            let fullSnapshot = view.snapshot()
                            let cropWidth: CGFloat = 800
                            let cropHeight: CGFloat = 900
                            let originX = (fullSnapshot.size.width - cropWidth) / 2
                            let originY = (fullSnapshot.size.height - cropHeight) / 2
                            let cropRect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
                            if let cgImage = fullSnapshot.cgImage?.cropping(to: cropRect) {
                                let croppedImage = UIImage(cgImage: cgImage, scale: fullSnapshot.scale, orientation: fullSnapshot.imageOrientation)
                                self.parent.capturedImage = croppedImage
                            } else {
                                self.parent.capturedImage = fullSnapshot
                            }
                        }
                    }
                }
            }
        }
    }
}

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
