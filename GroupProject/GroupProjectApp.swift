//
//  GroupProjectApp.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/12/23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct GroupProjectApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager: AuthenticationManager = AuthenticationManager()


  var body: some Scene {
    WindowGroup {
      NavigationView {
          AuthenticationView().environmentObject(authManager)
      }
    }
  }
}
