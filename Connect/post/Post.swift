//
//  Post.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//
import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let title: String
    let imagePath: String
    let creatorEmail: String
    let likes: [String?]
    let comments: [Comment]
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, imagePath, creatorEmail, likes, comments, createdAt
    }

    // ✅ Proper decoding initializer for Post
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        imagePath = try container.decode(String.self, forKey: .imagePath)
        creatorEmail = try container.decode(String.self, forKey: .creatorEmail)
        likes = try container.decodeIfPresent([String?].self, forKey: .likes) ?? []
        comments = try container.decodeIfPresent([Comment].self, forKey: .comments) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    // ✅ Manual initializer for internal use
    init(
        id: String,
        title: String,
        imagePath: String,
        creatorEmail: String,
        likes: [String?],
        comments: [Comment],
        createdAt: Date?
    ) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
        self.creatorEmail = creatorEmail
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
    }
}

struct Comment: Identifiable, Codable {
    let id: String
    let commenterEmail: String
    let text: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case commenterEmail = "sender"
        case text
        case createdAt
    }

    // Custom decoding for optional createdAt
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        commenterEmail = try container.decode(String.self, forKey: .commenterEmail)
        text = try container.decode(String.self, forKey: .text)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) // ✅ safe
    }

    // ✅ Add this manual initializer so you can create a Comment directly
    init(id: String, commenterEmail: String, text: String, createdAt: Date?) {
        self.id = id
        self.commenterEmail = commenterEmail
        self.text = text
        self.createdAt = createdAt
    }
}
