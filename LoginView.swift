import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isLoggedIn: Bool = false // Track the login state

    var body: some View {
        NavigationView {
            ZStack {
                Image("browse_background") // Name of your banner image
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all) // Ignore safe area to fill the entire screen

                VStack {

                    Text("Log Into Your Account")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: 240)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        )
                        .padding(.top, 50) // Add top padding to separate from the edge
                    Spacer() // Push content to the top

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: signIn) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            )
                    }
                    .padding()

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Spacer() // Push content to the top
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline) // Display navigation bar title inline
            .navigationBarHidden(true) // Hide the navigation bar
            .onAppear {
                // Navigate to MainContentView when isLoggedIn is true
                if isLoggedIn {
                    navigateToMainContentView()
                }
            }
            .fullScreenCover(isPresented: $isLoggedIn, content: MainContentView.init) // Present MainContentView when isLoggedIn is true
        }
    }

    func signIn() {
        guard email.hasSuffix("@fordham.edu") else {
            error = "Please use a @fordham.edu email"
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Sign-in failed with error: \(error.localizedDescription)")
                self.error = "Sign-in failed. Please check your email and password."
            } else {
                print("Sign-in successful")
                self.error = nil
                self.isLoggedIn = true // Set isLoggedIn to true upon successful sign-in
            }
        }
    }

    func navigateToMainContentView() {
        isLoggedIn = false // Reset isLoggedIn to false
        // Navigate to MainContentView programmatically
        // This is used in onAppear to ensure MainContentView is navigated to when isLoggedIn is true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
