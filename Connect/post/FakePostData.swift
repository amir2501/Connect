////
////  FakePostData.swift
////  Connect
////
////  Created by MacBook Pro M3 on 6/13/25.
////
//
//
//import Foundation
//
//struct FakePostData {
//    static let images = (1...30).map { "post_\($0)" } // Assumes assets named post_1, post_2, ..., post_30
//    static let descriptions = [
//        "Enjoying the sunny weather! ☀️",
//        "Throwback to this amazing day!",
//        "New adventures coming soon...",
//        "Feeling grateful today 🙏",
//        "When in doubt, travel 🌍",
//        "Weekend mood 💫",
//        "Catching flights ✈️ not feelings",
//        "Golden hour glow 🌅",
//        "Just chilling 😎",
//        "Work hard, play harder 🔥",
//        "Nature’s beauty 😍",
//        "Food = happiness 🍕",
//        "My happy place 💖",
//        "Dream big, hustle hard 🚀",
//        "Sundays are for rest 🌿",
//        "All smiles today 😊",
//        "Can’t get over this view!",
//        "Let the good vibes flow ✨",
//        "City lights and late nights 🌃",
//        "Me, myself & I 💁‍♂️",
//        "Take me back... 🛫",
//        "Be bold. Be brave.",
//        "Moments like these 💭",
//        "Fresh air & freedom 🏞",
//        "Blessed and obsessed 💙",
//        "Mood for the week 💼",
//        "Sunset state of mind 🌇",
//        "Simple things, big joys",
//        "Daydreaming 💭",
//        "Forever exploring 🌲"
//    ]
//
//    static func generateRandomPosts(count: Int) -> [Post] {
//        var posts = [Post]()
//
//        for _ in 0..<count {
//            let index = Int.random(in: 0..<images.count)
//            let likes = Int.random(in: 100...10_000)
//            let comments = Int.random(in: 10...300)
//            let reposts = Int.random(in: 5...150)
//            let saves = Int.random(in: 5...500)
//
//            posts.append(Post(
//                imageName: images[index],
//                description: descriptions[index],
//                likes: likes,
//                comments: comments,
//                reposts: reposts,
//                saves: saves
//            ))
//        }
//
//        return posts
//    }
//}
//
//
//extension FakePostData {
//    static let usernames = ["alice", "bob", "charlie", "dave", "eve", "zoe", "emma", "lucas",
//                            "mike", "sara", "john", "mia", "nick", "olivia", "nate"]
//
//    static let commentTexts = [
//        "Love this 😍", "So cool!", "Where is this?", "Amazing shot!", "Incredible view!",
//        "This is goals 🔥", "Wow, just wow", "I need to go here", "What a vibe!", "Aesthetic AF",
//        "Legendary moment", "So peaceful", "Wish I was there", "On my bucket list", "Iconic 🔥"
//    ]
//
//    static func generateComments() -> [Comment] {
//        let combinations = usernames.flatMap { username in
//            commentTexts.map { text in
//                Comment(username: username, text: text)
//            }
//        }
//
//        let count = Int.random(in: 25...70)
//        let uniqueCombinations = Array(combinations.shuffled().prefix(count))
//        return uniqueCombinations
//    }
//}
//
