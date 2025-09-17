//
//  SimpleUserProfileView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/18/25.
//


//
//  SimpleUserProfileView.swift
//  Connect
//

import SwiftUI

struct SimpleUserProfileView: View {
//    let email: String
    var email: String {
        UserDefaults.standard.string(forKey: "email") ?? "unknown@demo.com"
    }
    
    @State private var user: BackendUserWithFollowers? = nil
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else if let user = user {
                VStack(spacing: 16) {
                    // Avatar
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                    
                    // Name
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Email
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                Text("User not found")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            fetchUser()
        }
        .navigationTitle("User")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fetchUser() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/profile/\(email)") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(BackendUserWithFollowers.self, from: data) {
                    DispatchQueue.main.async {
                        self.user = decoded
                        self.isLoading = false
                    }
                }
            }
        }.resume()
    }
}
