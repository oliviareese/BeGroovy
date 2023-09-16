//
//  SignUpView.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/12/23.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State var signUpRequest = false
    
    func signUpWithEmail() {
        // dismiss the signup view if the user successfully creates an account
        Task {
            if await authManager.signUpWithEmail() {
                signUpRequest = true
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                VStack {
                    HStack {
                        Text("Email: ").padding(.leading, 30)
                        TextField("enter your email here", text: $authManager.email)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                    
                    HStack {
                        Text("Username: ").padding(.leading, 30)
                        TextField("enter your username here", text: $authManager.username)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                                                
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                    
                    HStack {
                        Text("Password: ").padding(.leading, 30)
                        SecureField("enter your password here", text: $authManager.password)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                    
                    
                    HStack {
                        Text("Confirm Password: ").padding(.leading, 30)
                        SecureField("re-enter your password", text: $authManager.confirmationPassword)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                
                Button(action: signUpWithEmail) {
                    if authManager.authenticationState == .authenticating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .greatestFiniteMagnitude)
                    } else {
                        Text("Sign Up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .greatestFiniteMagnitude)
                    }
                }
                .frame(maxWidth: .greatestFiniteMagnitude)
                .buttonStyle(.borderedProminent)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .padding(.bottom, 30)
            
                
                if !authManager.errorMsg.isEmpty {
                    Text(authManager.errorMsg).foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(destination: HomeView().environmentObject(PostsManager()), isActive: $signUpRequest) {
                    EmptyView()
                }
                
                VStack {
                    Text("Already have an account?").padding(3)
                    Button(action: {
                        authManager.switchStatus()
                    }) {
                        Text("Sign in here!")
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(AuthenticationManager())
    }
}
