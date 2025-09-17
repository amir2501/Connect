//
//  ChatBubbleView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/4/25.
//


//
//  ChatBubbleView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/4/25.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    let showSender: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if showSender && !isCurrentUser {
                    Text(message.sender)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: isCurrentUser ? .trailing : .leading)

                Text(timeAgo(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if !isCurrentUser { Spacer() }
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}