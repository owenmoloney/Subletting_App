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

struct Apartment2: Identifiable { // Define a data model for apartments
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

struct SortView: View {
    @State private var apartments: [Apartment2] = []
    @State private var selectedRoomates: ClosedRange<Int> = 0...10
    @State private var selectedBathrooms: ClosedRange<Int> = 0...3
    @State private var selectedRentRange: ClosedRange<Int> = 800...2000
    @State private var selectedGender = "All" // Default gender filter


    var body: some View {
        VStack {
            HStack {
                Text("Roommates:")
                    .padding(.leading)

                Slider(
                    value: Binding(
                        get: { Double(selectedRoomates.lowerBound) },
                        set: { selectedRoomates = Int($0)...selectedRoomates.upperBound }
                    ),
                    in: 0...10
                )
                .overlay(Text("\(selectedRoomates.lowerBound)"), alignment: .trailing) // Display the value

            }

            HStack {
                Text("Bathrooms:")
                    .padding(.leading)

                Slider(
                    value: Binding(
                        get: { Double(selectedBathrooms.lowerBound) },
                        set: { selectedBathrooms = Int($0)...selectedBathrooms.upperBound }
                    ),
                    in: 0...3
                )
                .overlay(Text("\(selectedBathrooms.lowerBound)"), alignment: .trailing) // Display the value

            }

            HStack {
                   Text("Rent: ")
                    .padding(.leading, 20) // Add leading padding to the text

                   ZStack(alignment: .leading) {
                       Slider(
                           value: Binding(
                               get: { Double(selectedRentRange.upperBound) },
                               set: { newValue in
                                   // Update the selectedRentRange based on the slider value
                                   selectedRentRange = 800...Int(newValue)
                               }
                           ),
                           in: Double(800)...Double(2000), // Set the range from 800 to 2000
                           step: 1 // Optional: Adjust step value as needed
                       )
                       .accentColor(.blue) // Set the slider's accent color

                       // Display the upperBound value to the right of the slider
                       Text("\(selectedRentRange.upperBound)")
                           .padding(.leading) // Adjust padding as needed
                           .offset(x: 180, y: 20) // Offset to position the text next to the slider thumb
                   }
                   .frame(width: 250) // Adjust the width of the ZStack to fit the slider and text
               }
            Picker("Gender", selection: $selectedGender) {
                            Text("All").tag("All")
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
            
                // Filtered list of apartments based on selected ranges for roommates and baths
            List(apartments.filter { apartment in
                selectedRoomates.contains(apartment.roomates) &&
                selectedBathrooms.contains(apartment.bath) &&
                selectedRentRange.contains(apartment.rent) &&
                (selectedGender == "All" || apartment.sex == selectedGender)
            }) { apartment in
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
                            .padding(.top, -170) // Align the VStack to the left edge
                        }
                    } else {
                        Spacer() // Add a spacer even if there's no image to maintain alignment
                    }
                    
                    VStack(alignment: .leading) {
                        Text(apartment.name)
                            .font(.system(size: 17))
                            .padding(.top, -70)
                            .padding(.horizontal, -150)
                        Text("Phone: \(apartment.phone)") // Display phone
                            .padding(.top, -60)
                            .padding(.horizontal, -150)
                        Text("Rent: $\(apartment.rent)") // Change price to rent
                            .padding(.top, -50)
                            .padding(.horizontal, -150)
                        Text("Roomates: \(apartment.roomates)") // Display roomates
                            .padding(.top, -40)
                            .padding(.horizontal, -150)
                        Text("Bath: \(apartment.bath)") // Display bath
                            .padding(.top, -30)
                            .padding(.horizontal, -250)
                        Text("Email: \(apartment.email)") // Display email
                            .padding(.top, -20)
                            .padding(.horizontal, -250)
                        Text("Utilities: \(apartment.utilities)") // Display utilities
                            .padding(.top, -10)
                            .padding(.horizontal, -250)
                        Text("Address: \(apartment.address)") // Change location to address
                            .padding(.top, 0)
                            .padding(.horizontal, -250)
                        Text("Gender: \(apartment.sex)") // Display phone
                            .padding(.top, 0)
                            .padding(.horizontal, -250)
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
                let rent = data["rent"] as? Int ?? 0
                let roomates = data["roomates"] as? Int ?? 0
                let bath = data["bath"] as? Int ?? 0
                let email = data["email"] as? String ?? ""
                let utilities = data["utilities"] as? String ?? ""
                let phone = data["phone"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let imageUrl = data["imageUrl"] as? String ?? ""
                let sex = data["sex"] as? String ?? ""

                // Only return apartments with two roommates
                    return Apartment2(
                        id: id,
                        name: name,
                        address: address,
                        rent: rent,
                        description: description,
                        roomates: roomates,
                        bath: bath,
                        email: email,
                        utilities: utilities,
                        phone: phone,
                        sex: sex,
                        imageUrl: imageUrl
                )
            }
        }
    }
}

struct SortView_Previews: PreviewProvider {
    static var previews: some View {
        SortView()
    }
}
