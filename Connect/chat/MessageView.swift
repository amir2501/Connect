//
//  MessageView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import SwiftUI

struct MessageView: View {
    @ObservedObject private var manager = ChatManager.shared
    @State private var showNewChatSheet = false
    @State private var currentUserEmail: String = UserDefaults.standard.string(forKey: "email") ?? ""

    private var sortedChats: [Chat] {
        manager.chatList
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedChats, id: \.chatId) { currentChat in
                    NavigationLink(
                        destination: ChatView(
                            chatTitle: currentChat.title,
                            recipientEmail: currentChat.participants.first { $0 != currentUserEmail } ?? "",
                            chatId: currentChat.chatId
                        )
                    ) {
                        ChatRow(chat: currentChat)
                    }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewChatSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewChatSheet) {
                NewChatSheet(isPresented: $showNewChatSheet)
            }
            .onAppear {
                if !currentUserEmail.isEmpty {
                    manager.fetchChats(for: currentUserEmail)
                } else {
                    print("❌ No email found in UserDefaults")
                }
            }
        }
    }
}

struct ChatRow: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(initials(from: chat.title))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(.headline)

                Text(chat.messages.last?.content ?? "Start chatting")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            if let lastTime = chat.messages.last?.timestamp {
                Text(shortTime(from: lastTime))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }

    private func initials(from name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    private func shortTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct Chat: Identifiable {
    var id: String { chatId } // This makes it identifiable for ForEach
    let chatId: String
    let title: String
    let participants: [String]
    var messages: [Message]
}

#Preview {
    MessageView()
}
