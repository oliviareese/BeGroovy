//
//  LoginView.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/12/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State var loginRequest = false
    
    func signInWithEmail() {
        // dismiss the login view if user successfully logged into their account
        Task {
            if await authManager.signInWithEmail() {
                loginRequest = true
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                VStack {
                    HStack {
                        Text("Email: ")
                            .padding(.leading, 30)
                        TextField("enter your email here", text: $authManager.email)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                    
                    
                    HStack {
                        Text("Password: ")
                            .padding(.leading, 30)
                        SecureField("enter your password here", text: $authManager.password)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                Button(action: signInWithEmail) {
                    if authManager.authenticationState == .authenticating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .greatestFiniteMagnitude)
                    } else {
                        Text("Login")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
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
                
                NavigationLink(destination: HomeView().environmentObject(PostsManager()), isActive: $loginRequest) {
                    EmptyView()
                }
                
                VStack {
                    Text("Don't have an account?").padding(3)
                    Button(action: {
                        authManager.switchStatus()
                    }) {
                        Text("Sign up here!")
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        .environmentObject(AuthenticationManager())
    }
}
