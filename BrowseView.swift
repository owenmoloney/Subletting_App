//
//  BrowseView.swift
//  Swift_FInal_Proj
//
//  Created by Owen Moloney on 4/5/24.
//
//
//  BrowseView.swift
//  Swift_FInal_Proj
//
//  Created by Owen Moloney on 4/5/24.
//
import SwiftUI
import Firebase
import URLImage // Import SwiftUI-URLImage library

struct Apartment: Identifiable { // Define a data model for apartments
    let id: String // Document ID
    let name: String
    let address: String // Change location to address
    let rent: Int // Change price to rent
    let description: String
    let roomates: Int
    let bath: Int
    let email: String
    let utilities: String
    let phone: String
    let sex: String
    let imageUrl: String // New property for image URL
}

struct BrowseView: View {
    let darkRed = Color(red: 0.5, green: 0, blue: 0) // Darker shade of red
    @State private var apartments: [Apartment] = []
    @State private var selectedRoomates: Int?
       @State private var selectedBathrooms: Int?
    @State private var selectedRentRange: ClosedRange<Int>?
    let currentUser = Auth.auth().currentUser // Get current user


    var body: some View {
 
    VStack{
            Spacer()
            ZStack { // Aligns content to the top right
                NavigationLink(destination: SortView()) {
                    Text("Customize Your Search-->")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(width: 235, height: 40) // Size of the square
                .background(darkRed) // Set background color to maroon
                .cornerRadius(60) // Apply corner radius to make it square
                .padding(.top, 0) // Ensure it aligns to the top
                .padding(.trailing, -80) // Ensure it aligns to the right
                .opacity(0.8)
                
                }
                
        List(apartments) { apartment in
            VStack {
                HStack {
                    if let imageUrl = apartment.imageUrl, let url = URL(string: imageUrl) {
                        VStack {
                            URLImage(url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100) // Adjust size as needed
                            }
                            .padding(.horizontal, -30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity, alignment: .leading)
                            // Align the VStack to the left edge
                            .padding(.top, -240)
                        }
                    } else {
                        VStack {
                                Text("No Image Provided")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, -10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(maxHeight: .infinity, alignment: .leading)
                                    .padding(.top, -200)
                            }
                    }
                    VStack(alignment: .leading) {
                        Text(apartment.name)
                            .font(.system(size:17))
                            .padding(.top, -70)
                            .padding(.horizontal, -50)
                        Text("Phone: \(apartment.phone)") // Display phone
                            .padding(.top, -60)
                            .padding(.horizontal, -50)
                        Text("Rent: $\(apartment.rent)") // Change price to rent
                            .padding(.top, -50)
                            .padding(.horizontal, -50)
                        Text("Roomates: \(apartment.roomates)") // Display roomates
                            .padding(.top, -40)
                            .padding(.horizontal, -50)
                        Text("Bath: \(apartment.bath)") // Display bath
                            .padding(.top, -30)
                            .padding(.horizontal, -50)
                        Text("Email: \(apartment.email)") // Display email
                            .padding(.top, -10)
                            .padding(.horizontal, -150)
                        Text("Utilities: \(apartment.utilities)") // Display utilities
                            .padding(.top, -10)
                            .padding(.horizontal, -150)
                        Text("Address: \(apartment.address)") // Change location to address
                            .padding(.top, 0)
                            .padding(.horizontal, -150)
                        Text("Gender: \(apartment.sex)") // Change location to address
                            .padding(.top, 0)
                            .padding(.horizontal, -150)
                        Button("Save to Favorites")
                            {
                                bookmarkApartment(apartment.id) // Function to add apartment to bookmarks
                            }
                            .padding()
                            .background(
                                    Rectangle()
                                    .fill(darkRed.opacity(0.9)) // Use darkRed color with opacity
                                    .frame(width: 150, height: 60)
                                    .cornerRadius(20) // Increase corner radius for more rounded edges
                            )
                            .foregroundColor(.black) // Set text color to black
                    }
                    .padding(.vertical, 50) // Add vertical padding to separate each item vertically
                }
                .padding() // Add padding to the whole row
            }
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 45) // Adjust height as needed
                .listRowInsets(EdgeInsets()) // Remove default padding for the background rectangle
        }
        .onAppear {
            fetchApartments() // Fetch apartments when the view appears
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack navigation view style
    }
  }

    func fetchApartments() {
        let db = Firestore.firestore()
        db.collection("apartments").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching apartments: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No apartments found")
                return
            }

            self.apartments = documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let address = data["address"] as? String ?? "" // Change location to address
                let rent = data["rent"] as? Int ?? 0 // Change price to rent
                let roomates = data["roomates"] as? Int ?? 0 // Retrieve roomates
                let bath = data["bath"] as? Int ?? 0 // Retrieve bath
                let email = data["email"] as? String ?? "" // Retrieve email
                let utilities = data["utilities"] as? String ?? "" // Retrieve utilities
                let phone = data["phone"] as? String ?? "" // Retrieve phone
                let description = data["description"] as? String ?? ""
                let imageUrl = data["imageUrl"] as? String ?? "" // Retrieve image URL
                let sex = data["sex"] as? String ?? ""
                return Apartment(id: id, name: name, address: address, rent: rent, description: description, roomates: roomates, bath: bath, email: email, utilities: utilities, phone: phone, sex: sex, imageUrl: imageUrl)
            }
        }
    }
    
    func bookmarkApartment(_ apartmentId: String) {
            guard let currentUser = currentUser else {
                print("No user signed in")
                return
            }

            let db = Firestore.firestore()
            let userRef = db.collection("users").document(currentUser.uid)

            userRef.updateData([
                "bookmarked": FieldValue.arrayUnion([apartmentId]) // Add apartmentId to "bookmarked"
            ]) { error in
                if let error = error {
                    print("Error bookmarking apartment: \(error.localizedDescription)")
                } else {
                    print("Apartment bookmarked successfully")
                }
            }
        }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
