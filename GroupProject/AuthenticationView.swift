//
//  AuthenticationView.swift
//  GroupProject
//
//  Created by Olivia Reese on 3/12/23.

import SwiftUI

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationManager

  var body: some View {
    VStack {
      switch viewModel.status {
      case .login:
        LoginView()
          .environmentObject(viewModel)
      case .signUp:
        SignUpView()
          .environmentObject(viewModel)
      }
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitle("")
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView().environmentObject(AuthenticationManager())
  }
}

