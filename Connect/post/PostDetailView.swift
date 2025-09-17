//
//  PostDetailView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var newComment: String = ""
    @State private var comments: [Comment] = []
    let saver = ImageSaver()
    
    @State private var isSendingComment = false
    @State private var userEmail: String = UserDefaults.standard.string(forKey: "email") ?? "anonymous@demo.com"

    private var imageURL: URL? {
        PostService.shared.imageURL(for: post.imagePath)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(post.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Image (if available)
            Group {
                if let url = imageURL {
                    PostImageView(url: url, saver: saver)
                }
            }

            // Comments List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(comments) { comment in
                        CommentRowView(comment: comment)
                    }
                }
                .padding(.top)
            }

            // Comment Input
            CommentInputView(newComment: $newComment) {
                guard !newComment.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                sendComment(text: newComment)
            }
        }
        .onAppear {
            self.comments = post.comments
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func sendComment(text: String) {
        guard !isSendingComment else { return }
        isSendingComment = true

        Task {
            defer { isSendingComment = false }

            let comment = ["sender": userEmail, "text": text]

            guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/posts/\(post.id)/comment") else {
                print("❌ Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: comment)
            } catch {
                print("❌ Failed to encode JSON:", error)
                return
            }

            do {
                let (_, response) = try await URLSession.shared.data(for: request)
            
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    
                    
                    let new = Comment(
                        id: UUID().uuidString,
                        commenterEmail: userEmail,
                        text: text,
                        createdAt: Date()
                        
                    )
                    comments.append(new)
                    newComment = ""
                } else {
                    print("❌ Server error: Invalid status code")
                }
            } catch {
                print("❌ Network or decoding error:", error)
            }
        }
    }
}

struct PostImageView: View {
    let url: URL
    let saver: ImageSaver

    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width - 16

            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.horizontal, 8)

                case .failure(_):
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(width: size, height: size)

                @unknown default:
                    EmptyView()
                }
            }
            .onLongPressGesture {
                if let vc = UIApplication.rootViewController {
                    saver.saveImageUrl(from: url, in: vc)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width - 16)
    }
}

struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.commenterEmail ?? "Anonymous")
                    .fontWeight(.semibold)
                    .foregroundColor(.figmaBlue)

                Text(comment.text)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}




struct CommentInputView: View {
    @Binding var newComment: String
    var onSubmit: () -> Void

    var body: some View {
        HStack {
            TextField("Add a comment...", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: onSubmit) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(.figmaBlue)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
extension UIApplication {
    static var rootViewController: UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
