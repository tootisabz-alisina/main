import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var extractedTexts: [String] = []
    
    // Parsed fields (update your parsing logic as needed)
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: String = ""
    @State private var idNumber: String = ""
    @State private var placeOfBirth: String = ""
    @State private var dateOfIssue: String = ""
    @State private var gender: String = ""
    @State private var nationality: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the cropped image
                if let image = inputImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .padding()
                }
                
                // Show extracted text details
                if !extractedTexts.isEmpty {
                    List {
                        Text("First Name: \(firstName)")
                        Text("Last Name: \(lastName)")
                        Text("Date of Birth: \(dateOfBirth)")
                        Text("ID Number: \(idNumber)")
                        Text("Place of Birth: \(placeOfBirth)")
                        Text("Date of Issue: \(dateOfIssue)")
                        Text("Gender: \(gender)")
                        Text("Nationality: \(nationality)")
                    }
                } else {
                    Text("No text extracted yet.")
                        .padding()
                }
                
                Button("Capture ID Card") {
                    showImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("ID Card Scanner")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage, onImagePicked: { image in
                performOCR(on: image)
            })
        }
    }
    
    // MARK: - OCR and Text Parsing
    
    func performOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var texts = [String]()
            for observation in observations {
                if let candidate = observation.topCandidates(1).first {
                    texts.append(candidate.string)
                }
            }
            DispatchQueue.main.async {
                self.extractedTexts = texts
                self.parseExtractedText()
            }
        }
        request.recognitionLevel = .accurate
        try? requestHandler.perform([request])
    }
    
    private func parseExtractedText() {
        let fullText = extractedTexts.joined(separator: "\n")
        debugPrint("Full Text: \(fullText)")
        
        // Example parsing using regular expressions (adjust as needed)
        if let idNumberRange = fullText.range(of: "ID Number\\s+([0-9-]+)", options: .regularExpression) {
            idNumber = String(fullText[idNumberRange].replacingOccurrences(of: "ID Number", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        if let nameLineRange = fullText.range(of: "Name SURNAME\\s+([^\\n]+)", options: .regularExpression) {
            let nameLine = String(fullText[nameLineRange])
            let cleanedName = nameLine.replacingOccurrences(of: "Name SURNAME", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            let tokens = cleanedName.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard tokens.count >= 2 else { return }
            let possibleSurname = tokens.last!
            if possibleSurname == possibleSurname.uppercased() {
                lastName = possibleSurname
                firstName = tokens.dropLast().joined(separator: " ")
            } else {
                firstName = tokens.first!
                lastName = tokens.count > 1 ? tokens[1] : ""
            }
        }
        
        if let dobRange = fullText.range(of: "Date of Birth\\s+([0-9/]+)", options: .regularExpression) {
            dateOfBirth = String(fullText[dobRange].replacingOccurrences(of: "Date of Birth", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        if let pobRange = fullText.range(of: "Place of Birth\\s+([A-Za-z]+)", options: .regularExpression) {
            placeOfBirth = String(fullText[pobRange].replacingOccurrences(of: "Place of Birth", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        if let doiRange = fullText.range(of: "Date of Issue\\s+([0-9/]+)", options: .regularExpression) {
            dateOfIssue = String(fullText[doiRange].replacingOccurrences(of: "Date of Issue", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        if let genderRange = fullText.range(of: "Gender\\s+([A-Za-z]+)", options: .regularExpression) {
            gender = String(fullText[genderRange].replacingOccurrences(of: "Gender", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        if let nationalityRange = fullText.range(of: "Nationality\\s+([A-Za-z]+)", options: .regularExpression) {
            nationality = String(fullText[nationalityRange].replacingOccurrences(of: "Nationality", with: "").trimmingCharacters(in: .whitespaces))
        }
    }
}

// MARK: - Image Picker with Built-in Cropping

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Use the edited image which is available when allowsEditing is true.
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
                parent.onImagePicked(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
                parent.onImagePicked(originalImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        // Enable editing to use iOS’s built-in cropping UI.
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
