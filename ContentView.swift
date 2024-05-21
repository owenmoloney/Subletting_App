import SwiftUI
import Firebase
import FirebaseCore // You might not need this import if you're using Firebase with SwiftUI

struct ContentView: View {
    let darkRed = Color(red: 0.5, green: 0, blue: 0) // Darker shade of red

    var body: some View {
        NavigationView {
        
            ZStack{
                Image("banner_image") // Name of your banner image
                    .resizable()
                    .scaledToFit() // Adjust the scaling as needed
                    .frame(height: 90) // Set a fixed height for the banner
                    .padding(.top, -300)
            
                Rectangle() // Background square with "FS"
                    .fill(darkRed) // Set the square's color
                    .frame(width: 500, height: 110) // Size of the square
                    .cornerRadius(5) // Rounded corners
                    .padding(.top,350)

                Rectangle()
                    .fill(darkRed)
                    .frame(width: 155, height: 155) // Adjust height as needed
                    .listRowInsets(EdgeInsets()) // Remove default padding for the background rectangle
                    .cornerRadius(10) // This rounds the corners

                VStack {
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .font(.title3)
                            .foregroundColor(.white) // Set the text color to white
                    }
                    .padding()
                    
                    NavigationLink(destination: SignupView()) {
                        Text("Signup")
                            .font(.title3)
                            .foregroundColor(.white) // Set the text color to white
                    }
                }
                
                Spacer() // Pushes the square to the bottom-right corner
                HStack{
                    Text("For all living purposes!") // Text within the square
                        .foregroundColor(.white) // White text color
                        .font(.system(size: 20, weight: .medium, design: .serif)) //Script-style font
                        .padding(.top,300)
                    
                        Rectangle() // Background square with "FS"
                            .fill(darkRed) // Set the square's color
                            .frame(width: 70, height: 70) // Size of the square
                            .cornerRadius(5) // Rounded corners
                            .padding(.top,350)
                            .overlay(
                                Text("F.S.") // Text within the square
                                    .foregroundColor(.white) // White text color
                                    .font(.system(size: 30, weight: .medium, design: .serif)) //Script-style font
                                    .padding(.top,300)
                                )
                }
                Text("Made for Fordham Students") // Text within the square
                    .foregroundColor(.white) // White text color
                    .font(.system(size: 20, weight: .medium, design: .serif)) //Script-style font
                    .padding(.top,390)
                Text("By Fordham Students") // Text within the square
                    .foregroundColor(.white) // White text color
                    .font(.system(size: 20, weight: .medium, design: .serif)) //Script-style font
                    .padding(.top,430)
                Rectangle() // Background square with "FS"
                    .fill(Color.white) // Fill with white
                    .frame(width: 325, height: 8) // Size of the square
                    .cornerRadius(10) // Rounded corners
                    .padding(.top,350)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

