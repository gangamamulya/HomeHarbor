//
//  AuthenticationView.swift
//  HomeHarbor
//
//  Created by Amulya Gangam on 1/23/24.
//
import SwiftUI
import GoogleSignIn
import UIKit

struct AuthenticationView: View {
    var userType: SplitWise.UserType
    @State private var selectedUserType: SplitWise.UserType? = nil
    @State private var isSignedIn = false
    @State private var signInError: Error?
    var body: some View {
            VStack {
                if isSignedIn {
                    switch userType {
                    case .owner:
                        OwnerMainView()
                    case .tenant:
                        RenterView()
                    }
                   }
                else {
                    Button("Google Sign in") {
                        self.signInWithGoogle()
                    }
                    Image("google")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                    
                }
                
            }
            .navigationTitle(isSignedIn ? "": "Authentication")
             .navigationBarBackButtonHidden(true)
            
            if let error = signInError {
                Text("Error: \(error.localizedDescription)")
            }
        
    }
    
    func signInWithGoogle() {
        // Retrieves root VC of the first scene connected to your app
        guard let presentingVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }

        // Starts the sign-in process by presenting the VC
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [self] user, error in
           // guard let self = self else { return }

            if let error = error {
                // Handle error
                self.signInError = error
                return
            }

            // Successful sign-in
            self.isSignedIn = true

            // Access the current user's profile
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                let userType = userType.rawValue
                let userEmail = currentUser.profile?.email ?? ""
                let userName = currentUser.profile?.name ?? ""
                

                // Call saveUserData
                CoreDataManager.shared.saveUserData(userType: SplitWise.UserType(rawValue: userType) ?? .owner, name: userName, email: userEmail)
                
              // delete data
               //CoreDataManager.shared.deleteUserData()
            }
        }
    }


    private func getRootViewController() -> UIViewController {
        //navigates through the structure of your app to find the screen currently being used.
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }//include scenes visble to user
            .compactMap { $0 as? UIWindowScene } //type cast scene to window scene. compact map is used to handle nil values
            .first?.windows //windows is an array of windows managed by scene. so it gets the array of windows managed by first scene
            .filter { $0.isKeyWindow } //the one presenting user input. used for presenting new content.
            .first?.rootViewController ?? UIViewController()//if no rootviewcontroller found return an empty view controller
    }
}

#Preview {
    AuthenticationView(userType: .tenant)
}

