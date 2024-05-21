import SwiftUI
import Firebase
import FirebaseFirestore
import URLImage


struct UserPostsView: View {
    let user: User // Receive the user object
    @State private var userApartments: [Apartment3] = []
    let onDelete: (Apartment3) -> Void // Closure to handle deletion
    @State private var apartmentToDelete: Apartment3?


    var body: some View {
        VStack {

            Text("Email: \(user.email)")
                .padding()

            Text("My Posts")
                .font(.title)
                .padding()

            if userApartments.isEmpty {
                Text("No posts found")
            } else {
            
                List(userApartments) { apartment in
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
                                    .padding(.top, -180)
                                }
                            } else {
                                Spacer() // Add a spacer even if there's no image to maintain alignment
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
                                    .padding(.top, -20)
                                    .padding(.horizontal, -150)
                                Text("Utilities: \(apartment.utilities)") // Display utilities
                                    .padding(.top, -10)
                                    .padding(.horizontal, -150)
                                Text("Address: \(apartment.address)") // Change location to address
                                    .padding(.top, 0)
                                    .padding(.horizontal, -150)
                                
                                Button(action: {
                                        // Invoke onDelete closure with the selected apartment
                                    apartmentToDelete = apartment
                                }) {
                                    Text("Delete Post")
                                        .foregroundColor(.red)
                                    }
                            }
                            .padding(.vertical, 50) // Add vertical padding to separate each item vertically
                        }
                        .padding() // Add padding to the whole row
                    }
                }
            }
        }
        .alert(item: $apartmentToDelete) { apartment in
                    Alert(
                        title: Text("Delete Post"),
                        message: Text("Are you sure you want to delete this post?"),
                        primaryButton: .destructive(Text("Yes")) {
                            onDelete(apartment)
                        },
                        secondaryButton: .cancel(Text("No"))
                    )
                }
        .onAppear {
            fetchUserApartments()
        }
    }

    func fetchUserApartments() {
        let db = Firestore.firestore()

        db.collection("apartments")
            .whereField("email", isEqualTo: user.email) // Fetch apartments by user's email
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user apartments: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No user apartments found")
                    return
                }

                self.userApartments = documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? ""
                    let address = data["address"] as? String ?? ""
                    let rent = data["rent"] as? Int ?? 0
                    let roomates = data["roomates"] as? Int ?? 0
                    let bath = data["bath"] as? Int ?? 0
                    let email = data["email"] as? String ?? ""
                    let utilities = data["utilities"] as? String ?? ""
                    let phone = data["phone"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let imageUrl = data["imageUrl"] as? String ?? ""
                    return Apartment3(id: id, name: name, address: address, rent: rent, description: description, roomates: roomates, bath: bath, email: email, utilities: utilities, phone: phone, imageUrl: imageUrl)
                }
            }
    }
    func deleteApartment(_ apartment: Apartment3) {
            let db = Firestore.firestore()
            db.collection("apartments").document(apartment.id).delete { error in
                if let error = error {
                    print("Error deleting apartment: \(error.localizedDescription)")
                } else {
                    // Remove the deleted apartment from the userApartments array
                    self.userApartments.removeAll(where: { $0.id == apartment.id })
                    print("Apartment deleted successfully")
                }
            }
        }
}
