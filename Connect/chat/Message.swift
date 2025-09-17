//
//  Message.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import Foundation

private var currentUserEmail: String {
    UserDefaults.standard.string(forKey: "userEmail") ?? ""
}

struct ChatResponse: Codable {
    let chatId: String
    let participants: [String]
    let messages: [Message]
    let groupName: String?

    var chatTitle: String {
        groupName ?? participants.filter { $0 != currentUserEmail }.joined(separator: ", ")
    }
}

struct Message: Codable, Identifiable {
    var id: UUID { UUID() } // generate ID locally
    let sender: String
    let content: String
    let timestamp: Date
}

//
//struct Message: Identifiable, Codable {
//    let id: UUID
//    let sender: String
//    let content: String
//    let timestamp: Date
//
//    init(sender: String, content: String, timestamp: Date = Date()) {
//        self.id = UUID()
//        self.sender = sender
//        self.content = content
//        self.timestamp = timestamp
//    }
//}
//
//
//struct ChatResponse: Codable {
//    let chatTitle: String
//    let messages: [Message]
//}

//struct Message: Codable, Identifiable {
//    let id = UUID()
//    let sender: String
//    let content: String
//    let timestamp: Date
//
//    enum CodingKeys: String, CodingKey {
//        case sender, content, timestamp
//    }
//}
