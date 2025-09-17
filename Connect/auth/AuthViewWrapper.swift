//
//  AuthViewWrapper.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/15/25.
//


import SwiftUI

struct AuthViewWrapper: View {
    let authType: AuthType?
    @Binding var isLoggedIn: Bool

    var body: some View {
        Group {
            if let authType {
                AuthView(authType: authType, isLoggedIn: $isLoggedIn)
                    .navigationBarBackButtonHidden(true)
            } else {
                EmptyView()
            }
        }
    }
}