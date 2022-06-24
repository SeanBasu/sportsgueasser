//
//  ContentView.swift
//  Sports Guessing Game
//
//  Created by Sean Basu on 6/23/22.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct ContentView: View {
    @State var sportName = " "
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage(named: "sports")
    
    var body: some View {
        HStack {
            VStack (alignment: .center, spacing: 20) {
                Text("Sports Prediction Game")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    //Spacer()
                Text("Example:")
                    .font(.system(.title, design: .rounded))
                Text("It looks like you play football")
                Image("dwaynejohnson")
                    .resizable()
                    .scaledToFit()
                Spacer()
                Text(sportName)
                if let i = inputImage {
                    Image(uiImage: i)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Button("Predict"){
                    buttonPressed()
                }
                .padding(.all, 14.0)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .font(.title)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func processImage() {
        self.showingImagePicker = false
        self.sportName = "Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageJPG = inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        let uploadURL = "https://askai.aiclub.world/fe7ba690-592a-4bcf-903b-93a8cc6dbfb2"
        AF.upload(imageB64, to: uploadURL).responseJSON { response in
            debugPrint(response)
            switch response.result {
            case .success(let responseJsonStr):
                print("\n\n Success value and JSON: \(responseJsonStr)")
                let myJson = JSON(responseJsonStr)
                let predictedValue = myJson["predicted_label"].string
                print("Saw predicted value \(String(describing: predictedValue))")
                var predictionMessage = ""
                if(predictedValue == "swimming" || predictedValue == "martial arts") {
                    predictionMessage = "It looks like you do \(predictedValue!)"
                }
                else {
                    predictionMessage = "It looks like you play \(predictedValue!)"
                }
                print(predictedValue!)
                self.sportName = predictionMessage
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Environment(\.presentationMode) var presentationMode
        @Binding var image: UIImage?
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            //picker.sourceType = .camera
            return picker
        }
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        }
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
