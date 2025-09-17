//
//  PostService.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/17/25.
//


import Foundation

class PostService {
    static let shared = PostService()
    private let baseURL = "https://media-storage-hackaton.onrender.com"

    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "\(baseURL)/connect/posts") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                print("Raw JSON:")
                print(String(data: data, encoding: .utf8)!)
                
                do {
                    let decoder = JSONDecoder()
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
                    }  // ✅ Handle ISO 8601 dates like "2025-07-24T09:52:14.420Z"

                    let posts = try decoder.decode([Post].self, from: data)
                    DispatchQueue.main.async {
                        completion(posts)
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    completion([])
                }
            } else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown")")
                completion([])
            }
        }.resume()
    }

    func imageURL(for imagePath: String) -> URL? {
        URL(string: "\(baseURL)/connect/img/\(imagePath)")
    }
}
