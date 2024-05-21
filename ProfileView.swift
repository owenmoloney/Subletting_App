import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import URLImage

struct User: Identifiable {
    let id: String // Document ID (usually the same as the uid)
    let email: String
    let password: String
}

struct Apartment3: Identifiable { // Define a data model for apartments
    let id: String // Document ID
    let name: String
    let address: String
    let rent: Int
    let description: String
    let roomates: Int
    let bath: Int
    let email: String
    let utilities: String
    let phone: String
    let imageUrl: String // Property for image URL
}

struct ProfileView: View {
    @State private var user: User?
    @State private var bookmarkedApartments: [Apartment3] = []
    @State private var isShowingPosts = false // Flag to control navigation


    var body: some View {
        NavigationView {
            VStack(alignment: .leading) { // Center alignment
                // Account Information Section
                if let user = user {
                    VStack(alignment: .leading) { // Use VStack for account information
                        Text("Account Information")
                            .font(.title) // More prominent heading
                            .padding(.top, -120)
                        
                        Button("My Posts") {
                            self.isShowingPosts = true
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                        .sheet(isPresented: $isShowingPosts) {
                            UserPostsView(user: user, onDelete: { apartment in
                                deleteApartment(apartment)
                            })
                        }
                        Text("Email: \(user.email)")
                            .padding(.top, -100)

                        Text("Password: \(user.password)")
                            .padding(.top, -90)
                        
                    }
                    // Centered heading for bookmarked apartments
                    Text("Saved Apartments")
                        .font(.headline)
                        .padding(.top, 10)

                    if bookmarkedApartments.isEmpty {
                        Text("No bookmarked apartments found")
                            .padding(.top, 10) // Space above this text
                    } else {
                        List(bookmarkedApartments) { apartment in
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
                                            .padding(.top, -200)
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

                                    }
                                    .padding(.vertical, 50) // Add vertical padding to separate each item vertically
                                }
                                .padding() // Add padding to the whole row
                            }
                        }
                    }
                } else {
                    Text("No user data found")
                        .padding(.top, 10) // Space between the top and this message
                }
            }
            .padding(10) // Padding for the entire content
            .background(Color(.systemGray6)) // Optional background color for visual separation
        }
        .onAppear {
            fetchCurrentUser()
            fetchBookmarkedApartments()
        }
    }


    func fetchCurrentUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user signed in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                let email = data?["email"] as? String ?? ""
                let password = data?["password"] as? String ?? ""
                self.user = User(id: currentUser.uid, email: email, password: password)
            } else {
                print("No user data found")
            }
        }
    }

    func fetchBookmarkedApartments() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user signed in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                guard let bookmarked = document.data()?["bookmarked"] as? [String] else {
                    print("No bookmarked data found")
                    return
                }

                // Use the list of document IDs to query the "apartments" collection
                db.collection("apartments")
                    .whereField("__name__", in: bookmarked)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching bookmarked apartments: \(error.localizedDescription)")
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("No bookmarked apartments found")
                            return
                        }

                        self.bookmarkedApartments = documents.compactMap { document in
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
        }
    }
        func deleteApartment(_ apartment: Apartment3) {
            let db = Firestore.firestore()
            db.collection("apartments").document(apartment.id).delete { error in
                if let error = error {
                    print("Error deleting apartment: \(error.localizedDescription)")
                } else {
                    // Remove the deleted apartment from the bookmarkedApartments array
                    self.bookmarkedApartments.removeAll(where: { $0.id == apartment.id })
                    print("Apartment deleted successfully")
                }
            }
        }

}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
