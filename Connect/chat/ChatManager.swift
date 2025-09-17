//
//  ChatManager.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import Foundation
import Combine

/// Handles all chat data and persistence.
final class ChatManager: ObservableObject {
    static let shared = ChatManager()
    
    /// Key: chat title; Value: messages in that chat
    @Published private(set) var conversations: [String: [Message]] = [:]
    
    private let storageKey = "SavedChats"
    
    // MARK: - Init
    
    private init() {
        loadMessages()
    }
    
    // MARK: - Public API
    
    /// Returns messages for a chat, sorted by time (oldest → newest).
    func messages(for chatTitle: String) -> [Message] {
        conversations[chatTitle]?.sorted { $0.timestamp < $1.timestamp } ?? []
    }
    
    /// Adds a new message and saves to persistent storage.
    func sendMessage(chatId: String, content: String, sender: String) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/chats/send") else {
            print("❌ Invalid URL")
            return
        }
        
        print(sender)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "chatId": chatId,
            "from": sender,
            "message": content
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to encode JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Send message error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📨 Send message response: \(httpResponse.statusCode)")
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let error = json["error"] as? String {
                        print("❌ Failed to send message: \(error)")
                    } else {
                        print("✅ Message sent successfully")
                    }
                } else {
                    print("📦 Send message response body:")
                    print(String(data: data, encoding: .utf8) ?? "No response body")
                }
            }
        }.resume()
    }
    
    /// Remove every message in a specific chat.
    func clearChat(_ chatTitle: String) {
        conversations[chatTitle] = []
        saveMessages()
    }
    
    /// Remove all chats (useful for debugging).
    func clearAll() {
        conversations.removeAll()
        saveMessages()
    }
    /// fetches chats
    func fetchChats(for email: String) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/chats/\(email)") else {
            print("❌ Invalid URL")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("🌐 Response status code: \(response.statusCode)")
            }

            guard let data = data else {
                print("❌ No data returned from backend")
                return
            }

            // DEBUG: Print raw JSON
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON from backend:\n\(rawJSON)")
            }

            do {
                let decoded = try decoder.decode([ChatResponse].self, from: data)
                var updatedConversations: [String: [Message]] = [:]

                for chat in decoded {
                    let title = chat.chatTitle
                    updatedConversations[title] = chat.messages
                }

                DispatchQueue.main.async {
                    self.conversations = updatedConversations
                    self.saveMessages()
                    print("✅ Successfully fetched and updated chats")
                }

            } catch {
                print("❌ Decoding error: \(error)")
            }

        }.resume()
    }
    
    
    
    // Put this inside the ChatManager class
    var chatList: [Chat] {
        conversations.map { (title, messages) in
            let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
            let participants = extractParticipants(from: title)
            return Chat(
                chatId: title, // assuming title is used as chatId
                title: title,
                participants: participants,
                messages: sortedMessages
            )
        }
        .sorted { a, b in
            let aTime = a.messages.last?.timestamp ?? .distantPast
            let bTime = b.messages.last?.timestamp ?? .distantPast
            return aTime > bTime
        }
    }

    private func extractParticipants(from title: String) -> [String] {
        return title.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    // MARK: - Persistence
    
    private func saveMessages() {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadMessages() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let saved = try? JSONDecoder().decode([String: [Message]].self, from: data)
        else { return }
        
        conversations = saved
    }
}

