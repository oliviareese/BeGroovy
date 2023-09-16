//
//  AuthenticationManager.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/12/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationStatus {
  case login
  case signUp
}

@MainActor
class AuthenticationManager: ObservableObject {
  @Published var email = ""
  @Published var username = ""
  @Published var password = ""
  @Published var confirmationPassword = ""

  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var status: AuthenticationStatus = .login

  @Published var isValid  = false
  @Published var errorMsg = ""
  @Published var user: User?
  @Published var displayName = ""

  init() {
    registerAuthStateHandler()
      
      self.isValid = isInputValid(email: self.email, username: self.username, password: self.password, confirmationPassword: self.confirmationPassword, status: self.status)
  }
    
    func isInputValid(email: String, username: String, password: String, confirmationPassword: String, status: AuthenticationStatus) -> Bool {
        if status == .login {
            if email.isEmpty || username.isEmpty || password.isEmpty {
                return false
            } else {
                return true
            }
        } else {
            if email.isEmpty || username.isEmpty || password.isEmpty || confirmationPassword.isEmpty {
                return false
            } else {
                if !(password == confirmationPassword) {
                    return false
                }
                
                return true
            }
        }
    }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.email ?? ""
      }
    }
  }

  func switchStatus() {
    if status == .login {
        status = .signUp
    } else {
        status = .login
    }
      
    errorMsg = ""
  }

  func reset() {
    status = .login
    email = ""
    username = ""
    password = ""
    confirmationPassword = ""
  }
}


extension AuthenticationManager {
  func signInWithEmail() async -> Bool {
    authenticationState = .authenticating
    do {
      try await Auth.auth().signIn(withEmail: self.email, password: self.password)
      return true
    }
    catch  {
      print(error)
      errorMsg = "Incorrect email or password"
      authenticationState = .unauthenticated
      return false
    }
  }

  func signUpWithEmail() async -> Bool {
    authenticationState = .authenticating
      guard isInputValid(email: email, username: username, password: password, confirmationPassword: confirmationPassword, status: .signUp) else {
          if email.isEmpty || username.isEmpty || password.isEmpty || confirmationPassword.isEmpty {
            errorMsg = "A field cannot be empty"
        } else if !(password == confirmationPassword) {
            errorMsg = "Password and confirmation password must match"
        }
        
        authenticationState = .unauthenticated
        return false
    }
    do  {
        try await Auth.auth().createUser(withEmail: email, password: password)
        
        guard let user = Auth.auth().currentUser else {
            print("Error: User not found")
            return false
        }
        
        let userData = ["email": email, "username": username, "uid": user.uid]
        
        Firestore.firestore().collection("users").document(user.uid).setData(userData) { (error) in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    self.errorMsg = error.localizedDescription
                    self.authenticationState = .unauthenticated
                    return
                }
            
                print("User data saved successfully")
        }
        
        return true
    }
    catch {
      print(error)
      errorMsg = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signOut() {
    do {
      try Auth.auth().signOut()
    }
    catch {
      print(error)
      errorMsg = error.localizedDescription
    }
  }

  func deleteAccount() async -> Bool {
    do {
      try await user?.delete()
      return true
    }
    catch {
      errorMsg = error.localizedDescription
      return false
    }
  }
}
