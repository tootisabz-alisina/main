//import SwiftUI
//import AVFoundation
//import Vision
//
//struct ContentView: View {
//    @State private var instruction: String = "Please position your face in the frame."
//    @State private var isFaceDetected: Bool = false
//    @State private var isHeadTurnedRight: Bool = false
//    @State private var isHeadTurnedLeft: Bool = false
//    @State private var isFaceVerified: Bool = false
//    @State private var isAccessoryDetected: Bool = false
//    @State private var currentStep: Int = 0 // Track the current step in the flow
//
//    var body: some View {
//        ZStack {
//            // Camera View in the Background
//            CameraView(
//                isFaceDetected: $isFaceDetected,
//                isHeadTurnedRight: $isHeadTurnedRight,
//                isHeadTurnedLeft: $isHeadTurnedLeft,
//                isFaceVerified: $isFaceVerified,
//                isAccessoryDetected: $isAccessoryDetected,
//                currentStep: $currentStep
//            )
//            .edgesIgnoringSafeArea(.all)
//
//            // Overlay for Instructions
//            VStack {
//                Spacer()
//                Text(instruction)
//                    .font(.headline)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.bottom, 30)
//            }
//        }
//        .onChange(of: isFaceDetected) { detected in
//            if detected && currentStep == 0 {
//                currentStep = 1 // Move to the next step
//                instruction = "Please turn your head to the left."
//            }
//        }
//        .onChange(of: isHeadTurnedRight) { turnedRight in
//            if turnedRight && currentStep == 1 {
//                currentStep = 2 // Move to the next step
//                instruction = "Please turn your head to the right."
//            }
//        }
//        .onChange(of: isHeadTurnedLeft) { turnedLeft in
//            if turnedLeft && currentStep == 2 {
//                currentStep = 3 // Move to the next step
//                instruction = "Verifying face..."
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    if !isAccessoryDetected {
//                        isFaceVerified = true
//                        print("true") // Print true to the console
//                    }
//                }
//            }
//        }
//        .onChange(of: isAccessoryDetected) { accessoryDetected in
//            if accessoryDetected {
//                instruction = "Please remove any accessories (mask, glasses, hat)."
//            }
//        }
//    }
//}
//
//struct CameraView: UIViewRepresentable {
//    @Binding var isFaceDetected: Bool
//    @Binding var isHeadTurnedRight: Bool
//    @Binding var isHeadTurnedLeft: Bool
//    @Binding var isFaceVerified: Bool
//    @Binding var isAccessoryDetected: Bool
//    @Binding var currentStep: Int
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .high
//
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//              let input = try? AVCaptureDeviceInput(device: device),
//              captureSession.canAddInput(input) else {
//            return view
//        }
//
//        captureSession.addInput(input)
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
//        if captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            captureSession.startRunning()
//        }
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            layer.frame = uiView.bounds
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//        var parent: CameraView
//
//        init(parent: CameraView) {
//            self.parent = parent
//        }
//
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//            let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
//                guard let self = self else { return }
//                self.handleFaceDetection(request: request, error: error)
//            }
//
//            do {
//                try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]).perform([request])
//            } catch {
//                print("Face detection failed: \(error)")
//            }
//        }
//
//        private func handleFaceDetection(request: VNRequest, error: Error?) {
//            if let error = error {
//                print("Face detection error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let face = (request.results as? [VNFaceObservation])?.first else {
//                Task { @MainActor in
//                    parent.isFaceDetected = false
//                }
//                return
//            }
//
//            Task { @MainActor in
//                parent.isFaceDetected = true
//
//                // Check head orientation
//                if let yaw = face.yaw?.doubleValue {
//                    if parent.currentStep == 1 && yaw > 0.2 { // Turn right
//                        parent.isHeadTurnedRight = true
//                    } else if parent.currentStep == 2 && yaw < -0.2 { // Turn left
//                        parent.isHeadTurnedLeft = true
//                    }
//                }
//            }
//        }
//    }
//}
