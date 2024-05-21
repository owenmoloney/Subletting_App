//
//  MainContentView.swift
//  Subletting_Final
//
//  Created by Owen Moloney on 4/18/24.
//

import SwiftUI
import Firebase
import FirebaseCore // You might not need this import if you're using Firebase with SwiftUI

struct MainContentView: View {
    let darkRed = Color(red: 0.5, green: 0, blue: 0) // Darker shade of red

    var body: some View {
        NavigationView {
            ZStack{
                Image("main_background") // Name of your banner image
                    .resizable()
                    .scaledToFit() // Adjust the scaling as needed
                    .frame(height: 600) // Set a fixed height for the banner
                    .padding(.top, -20)
                Image("Fordham_Housing") // Name of your banner image
                    .resizable()
                    .scaledToFit() // Adjust the scaling as needed
                    .frame(height: 90) // Set a fixed height for the banner
                    .padding(.top, -320)
                Rectangle() // Background square with "FS"
                    .fill(darkRed)// Fill with white
                    .opacity(0.7) // Set opacity to 50%
                    .frame(width: 235, height: 160) // Size of the square
                    .cornerRadius(8) // Rounded corners
                    .padding(.top, -20)
            VStack {
                NavigationLink(destination: ProfileView()) {
                    Text("My Profile-->")
                        .font(.title3)
                        .padding(.bottom, 15)
                        .foregroundColor(.white) // White text color

                }

                NavigationLink(destination: SubmitView()) {
                    Text("Submit Your Apartment")
                        .font(.title3)
                        .padding(.bottom, 15)
                        .foregroundColor(.white) // White text color

                }
                
                NavigationLink(destination: BrowseView()) {
                    Text("Browse Apartments")
                        .font(.title3)
                        .padding(.bottom, 15)
                        .foregroundColor(.white) // White text color

                }
        }
                Text("Includes Rose Hill and Lincoln Center")
                    .padding(.top, 420)

    }
            .navigationBarBackButtonHidden(true) // Hide the back button
        }
    }
}
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
