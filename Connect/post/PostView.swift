import SwiftUI
import UIKit

struct PostView: View {
    let post: Post
    let saver = ImageSaver()
    let currentUserEmail: String
    
    @State private var isLiked = false
    @State private var likeCount: Int

    init(post: Post, currentUserEmail: String = UserDefaults.standard.string(forKey: "email") ?? "unknown@demo.com") {
        self.post = post
        self.currentUserEmail = currentUserEmail

        let cleanedLikes = post.likes.compactMap { $0 }

        _likeCount = State(initialValue: cleanedLikes.count)
        _isLiked = State(initialValue: cleanedLikes.contains(currentUserEmail))
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = PostService.shared.imageURL(for: post.imagePath) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: 300)
                            .clipped()
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                            .onLongPressGesture {
                                if let vc = getRootViewController() {
                                    saver.saveImage(from: url, in: vc)
                                }
                            }
                    case .failure(let error):
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Failed to load image")
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.95, height: 300)
                        .onAppear {
                            print("❌ Failed to load image from \(url): \(error.localizedDescription)")
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Invalid image URL")
                    .foregroundColor(.red)
            }

            Text(post.title)
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    likePost(postId: post.id, userEmail: currentUserEmail)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likeCount)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }

                Spacer()

                Label("\(post.comments.count)", systemImage: "bubble.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

        }
        .frame(width: UIScreen.main.bounds.width * 0.95)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
    func likePost(postId: String, userEmail: String) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/posts/\(postId)/like") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "userEmail": userEmail
        ]

        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Like error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            } else {
                print("Unexpected server response.")
            }
        }.resume()
    }
}

extension View {
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return nil
        }
        
        var topController = rootVC
        while let presentedVC = topController.presentedViewController {
            topController = presentedVC
        }
        return topController
    }
}
