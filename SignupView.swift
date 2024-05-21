import SwiftUI
import Firebase
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isPasswordMatch: Bool = true
    @State private var isSignedUp: Bool = false
    
    var body: some View {
        ZStack{
            Image("browse_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all) // Ignore safe area to fill the entire screen

        VStack {
            // Text fields for email, password, and confirm password
            // ...
            Text("Register Your Account")
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
                .padding(.bottom, 40)

            TextField("Email", text: $email)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .onChange(of: email) { newValue in
                                isEmailValid = newValue.hasSuffix("@fordham.edu")
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .foregroundColor(isEmailValid ? .primary : .red) // Highlight invalid email
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1) // Show red border for invalid email
                            )
                            .padding(.horizontal, 40) // Add horizontal padding to the VStack

                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .textContentType(.password)
                            .padding(.horizontal, 40) // Add horizontal padding to the VStack

                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .onChange(of: confirmPassword) { newValue in
                                isPasswordMatch = newValue == password
                            }
                            .textContentType(.password)
                            .foregroundColor(isPasswordMatch ? .primary : .red) // Highlight password mismatch
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isPasswordMatch ? Color.clear : Color.red, lineWidth: 1) // Show red border for password mismatch
                            )
                            .padding(.horizontal, 40) // Add horizontal padding to the VStack


            Button(action: signUp) {
                Text("Sign Up")
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
            // Navigate to MainContentView if sign-up successful
    
        .padding()
        .navigationBarTitle("Sign Up", displayMode: .inline)
        .onAppear {
            // Navigate to MainContentView when isLoggedIn is true
            if isSignedUp {
                navigateToMainContentView()
            }
        }
        .fullScreenCover(isPresented: $isSignedUp, content: MainContentView.init) // Present MainContentView when isLoggedIn is true
        }
    }
}
    func signUp() {
            guard isEmailValid && isPasswordMatch else {
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                } else if let authResult = authResult {
                    let db = Firestore.firestore()
                    db.collection("users").document(authResult.user.uid).setData([
                        "email": email,
                        "password": password
                    ]) { error in
                        if let error = error {
                            print("Error writing user data to Firestore: \(error.localizedDescription)")
                        } else {
                            print("User data written to Firestore successfully")
                            
                            // Send email verification
                            authResult.user.sendEmailVerification { error in
                                if let error = error {
                                    print("Error sending verification email: \(error.localizedDescription)")
                                } else {
                                    print("Verification email sent successfully")
                                    isSignedUp = true
                                }
                            }
                        }
                    }
                }
            }
    }
    func navigateToMainContentView() {
        isSignedUp = false // Reset isLoggedIn to false
        // Navigate to MainContentView programmatically
        // This is used in onAppear to ensure MainContentView is navigated to when isLoggedIn is true
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
