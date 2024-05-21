//
//  Subletting_FinalApp.swift
//  Subletting_Final
//
//  Created by Owen Moloney on 4/15/24.
//

import SwiftUI
import Firebase

@main
struct Subletting_FinalApp: App {
    init() {
          FirebaseApp.configure()
      }
      
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
