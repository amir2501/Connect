//
//  BackendNotification.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/18/25.
//


//
//  NotificationsView.swift
//  Connect
//

import SwiftUI

struct BackendNotification: Identifiable, Decodable {
    let id: String
    let message: String
    let createdAt: String
    let fromUser: String?
}

struct NotificationsView: View {
    var email: String {
        UserDefaults.standard.string(forKey: "email") ?? "unknown@demo.com"
    }
    
    @State private var notifications: [BackendNotification] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else if notifications.isEmpty {
                Text("No notifications yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(notifications) { notif in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(notif.message)
                            .font(.body)
                        
                        if let from = notif.fromUser {
                            Text("From: \(from)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(formatDate(notif.createdAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchNotifications()
        }
    }
    
    private func fetchNotifications() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/notifications/\(email)") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let data = data {
                if let decoded = try? JSONDecoder().decode([BackendNotification].self, from: data) {
                    DispatchQueue.main.async {
                        self.notifications = decoded
                    }
                } else {
                    print("❌ Failed to decode notifications")
                }
            }
        }.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        // crude formatter (adjust to match your backend date format)
        return String(dateString.prefix(10))
    }
}