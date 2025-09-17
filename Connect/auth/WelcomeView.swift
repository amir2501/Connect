//
//  WelcomeView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/15/25.
//


import SwiftUI

struct WelcomeView: View {
    @Binding var selectedAuthType: AuthType?
    @Binding var isLoggedIn: Bool
    @State private var navigateToAuthView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to Connect!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.figmaBlue)

                VStack(spacing: 12) {
                    Button("Login") {
                        selectedAuthType = .login
                        navigateToAuthView = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.figmaBlue)

                    Button("Register") {
                        selectedAuthType = .register
                        navigateToAuthView = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.figmaBlue)
                }

                NavigationLink(
                    destination: AuthViewWrapper(authType: selectedAuthType, isLoggedIn: $isLoggedIn),
                    isActive: $navigateToAuthView
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
        }
    }
}
extension Color {
    static let figmaBlue = Color(red: 26 / 255, green: 115 / 255, blue: 232 / 255)
}

//
//#Preview {
//    WelcomeView()
//}
