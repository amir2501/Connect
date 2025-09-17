//
//  ContentView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/8/25.
//
import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var selectedAuthType: AuthType? = nil

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
            } else {
                WelcomeView(selectedAuthType: $selectedAuthType, isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Check if user data exists in UserDefaults
            if let _ = UserDefaults.standard.string(forKey: "email") {
                isLoggedIn = true
            }
        }
    }
}

#Preview {
    ContentView()
}
