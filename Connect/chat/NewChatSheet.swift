//
//  NewChatSheet.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/4/25.
//

import SwiftUI

struct NewChatSheet: View {
    @AppStorage("email") private var userEmail = ""
    @Binding var isPresented: Bool
    @State private var users: [ConnectUser] = []
    @State private var isLoading = true
    @State private var showError = false
    

    var body: some View {
        NavigationView {
            List {
                ForEach(users) { user in
                    if user.email != userEmail {
                        Button(action: {
                            createChat(with: user.email)
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.6))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(initials(from: user.name))
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                    )

                                Text(user.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear(perform: fetchUsers)
            .overlay {
                if isLoading {
                    ProgressView()
                } else if showError {
                    Text("Failed to load users")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            print("🧾 Loaded userEmail from AppStorage: \(userEmail)")
        }
    }
        

    func initials(from name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    func fetchUsers() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/users") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([ConnectUser].self, from: data)
                    DispatchQueue.main.async {
                        self.users = users
                        self.isLoading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showError = true
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showError = true
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func createChat(with recipientEmail: String) {
        print("💌 Creating chat from: \(userEmail), to: \(recipientEmail)")
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/chats/create") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body: [String: Any] = [
            "from": userEmail,
            "to": recipientEmail,
            "type": 2
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpRes = response as? HTTPURLResponse {
                print("📨 Chat creation response: \(httpRes.statusCode)")
            }
            if let data = data {
                print("📦 Chat creation response body: \(String(data: data, encoding: .utf8) ?? "nil")")
            }

            DispatchQueue.main.async {
                isPresented = false
                ChatManager.shared.fetchChats(for: userEmail)
            }
        }.resume()
    }
}

struct ConnectUser: Codable, Identifiable {
    let id = UUID() // Only local; not from backend
    let email: String
    let name: String

    // Make sure id is not conflicting with decoding
    private enum CodingKeys: String, CodingKey {
        case email, name
    }
}
