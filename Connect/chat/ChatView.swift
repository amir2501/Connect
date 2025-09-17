///
//  ChatView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import SwiftUI

struct ChatView: View {
    let chatTitle: String
    @ObservedObject private var manager = ChatManager.shared
    @AppStorage("email") private var currentUser: String = ""
    @State private var newMessage = ""
    let recipientEmail: String  // Add this
    let chatId: String

    
    private var messages: [Message] {
        manager.messages(for: chatTitle)
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { message in
                            ChatBubbleView(
                                message: message,
                                isCurrentUser: message.sender == currentUser,
                                showSender: message.sender != currentUser // optional: show sender for group chat
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Message input bar
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                Button(action: {
                    manager.sendMessage(chatId: chatId, content: newMessage, sender: currentUser)
                    newMessage = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle(chatTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

