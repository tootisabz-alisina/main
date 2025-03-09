////
////  KYC.swift
////  ContinueLearing
////
////  Created by TOTI SABZ on 2/19/25.
////
//
//import Vision
//
//func processFrame(sampleBuffer: CMSampleBuffer) {
//    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//    let request = VNDetectFaceRectanglesRequest { (request, error) in
//        if let results = request.results as? [VNFaceObservation] {
//            for face in results {
//                // Check for accessories (e.g., glasses)
////                if face.hasGlasses {
////                    print("User is wearing glasses")
////                }
////
////                // Perform liveness detection (basic example)
////                if face.hasSmile {
////                    print("User is smiling (liveness detected)")
////                }
//            }
//        }
//    }
//
//    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//    try? handler.perform([request])
//}
//
//import SwiftUI
//import AVFoundation
//
//struct CameraView: UIViewRepresentable {
//    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//        var parent: CameraView
//
//        init(parent: CameraView) {
//            self.parent = parent
//        }
//
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            // Process the frame for face detection
//            parent.processFrame(sampleBuffer: sampleBuffer)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//
//        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
//            return view
//        }
//        captureSession.addInput(input)
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = view.bounds
//        view.layer.addSublayer(previewLayer)
//
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
//        captureSession.addOutput(videoOutput)
//
//        // Start the session on a background thread to avoid blocking the main thread.
//        DispatchQueue.global(qos: .userInitiated).async {
//            captureSession.startRunning()
//        }
//        
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {}
//
//    func processFrame(sampleBuffer: CMSampleBuffer) {
//        // Implement face detection here
//    }
//}
