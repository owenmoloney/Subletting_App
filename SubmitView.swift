//
//  SumbitView.swift
//  Subletting_Final
//
//  Created by Owen Moloney on 4/16/24.
//

import SwiftUI
import Firebase
import UIKit

struct SubmitView: View {
    @State private var apartmentName = ""
    @State private var address = ""
    @State private var rent = 0
    @State private var roomates = 0
    @State private var bath = 0
    @State private var email = ""
    @State private var utilities = ""
    @State private var phone = ""
    @State private var sex = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSubmitted = false

    var body: some View {
        VStack {
            Text("Submit Your Apartment")
            
            ScrollView {
                LazyVStack {
                    // Text fields for apartment information
                    TextField("Your Name", text: $apartmentName)
                        .padding()
                    
                    Group {
                        TextField("Address (Not Required)", text: $address)
                            .padding()
                        
                        HStack(spacing: 6) {
                            Text("Rent: ")
                            TextField("Rent", value: $rent, formatter: NumberFormatter())
                                .frame(width: 40)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Roomates: ")
                            TextField("Amount of Roomates", value: $roomates, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 20)
                            
                            Text("Baths: ")
                            TextField("Amount of Baths", value: $bath, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 20)
                        }
                        
                        TextField("Email", text: $email)
                            .padding()
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        TextField("Phone", text: $phone)
                            .padding()
                        TextField("Male or Female", text: $sex)
                            .padding()
                        TextField("List any utilities included in Rent?", text: $utilities)
                            .padding()
                    }
                    
                    // Image picker to allow selecting or capturing an image
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .padding()
                    }
                    
                    Button("Add Picture") {
                        showImagePicker = true
                    }
                    .padding()
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage, isShown: $showImagePicker)
                    }
                    
                    Spacer() // Move the submit button to the bottom
                    Button("Submit") {
                        // Save apartment data to Firebase along with the image
                        saveApartmentData()
                    }
                    .padding()
                }
                .padding(.horizontal) // Add horizontal padding to LazyVStack
            }
        }
        .fullScreenCover(isPresented: $isSubmitted, content: MainContentView.init)
    }
    
    func uploadImageToStorage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        // Generate a unique filename for the image
        let filename = UUID().uuidString
        // Create a reference to the Firebase Storage location where the image will be stored
        let storageRef = Storage.storage().reference().child("images/\(filename)")
        // Convert the UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Error converting image to data")
            completion(nil)
            return
        }
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image to storage: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // If the upload is successful, get the download URL of the uploaded image
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                // Return the download URL
                completion(url)
            }
        }
    }
    func saveApartmentData() {
        // Save apartment data to Firebase
        let db = Firestore.firestore()
        let documentReference = db.collection("apartments").document() // Get a reference to a new document
        
        // Provide default values for empty fields
        let defaultEmail = ""
        let defaultUtilities = ""
        let defaultPhone = ""
        
        documentReference.setData([
            "name": apartmentName,
            "address": address,
            "rent": rent,
            "sex": sex,
            "roomates" : roomates,
            "bath" : bath,
            "email" : email.isEmpty ? defaultEmail : email,
            "utilities" :  utilities.isEmpty ? defaultUtilities : utilities,
            "phone" : phone.isEmpty ? defaultPhone : phone,
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
                // Show an alert or provide feedback to the user about the error
                return
            }
            
            // If the document is added successfully, upload the selected image
            if let image = selectedImage {
                uploadImageToStorage(image) { imageUrl in
                    if let imageUrl = imageUrl {
                        // Image upload successful, save the imageUrl to Firestore
                        documentReference.updateData(["imageUrl": imageUrl.absoluteString]) { error in
                            if let error = error {
                                print("Error updating document with image URL: \(error)")
                                // Show an alert or provide feedback to the user about the error
                                return
                            }
                            print("Document updated with image URL: \(imageUrl.absoluteString)")
                            
                            // Set isSubmitted to true to trigger navigation
                            isSubmitted = true
                        }
                    }
                }
            } else {
                // If no image to upload, just set isSubmitted to true
                isSubmitted = true
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            parent.isShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
}

struct SubmitView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitView()
    }
}
