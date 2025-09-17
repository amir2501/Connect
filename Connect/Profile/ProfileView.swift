import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let userImage: String
    let message: String
    let relatedPostImage: String
}

struct Profile: Codable {
    let followers: [String]
    let following: [String]
}

struct ProfileView: View {
    @State private var selectedTab = "Posts"
    @State private var isLoading = true
    @State private var showSettings = false

    @State private var name = ""
    @State private var bio = ""
    @State private var posts: [Post] = []
    
    @State private var followersCount = 0
    @State private var followingCount = 0

    var currentUserEmail: String {
        UserDefaults.standard.string(forKey: "email") ?? "unknown@demo.com"
    }

    let tabs = ["Posts", "Likes"]

    var filteredPosts: [Post] {
        posts.filter { $0.creatorEmail == currentUserEmail }
    }

    var likedPostsByOthers: [Post] {
        posts.filter { post in
            post.likes.contains(where: { $0 != currentUserEmail })
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            profileHeader
                            statsSection
                            tabSelector
                            tabContent
                        }
                        .padding(.bottom, 32)
                        .padding(.top, 8) // small breathing space, no huge gap
                    }
                }
            }
            .onAppear {
                name = UserDefaults.standard.string(forKey: "name") ?? ""
                bio = UserDefaults.standard.string(forKey: "bio") ?? ""
                fetchPosts()
                fetchProfile()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    private func fetchPosts() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/posts") else { return }

        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let date = formatter.date(from: dateStr) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(dateStr)"
                )
            }
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedPosts = try decoder.decode([Post].self, from: data)
                    DispatchQueue.main.async {
                        self.posts = decodedPosts
                        self.isLoading = false
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    DispatchQueue.main.async { self.isLoading = false }
                }
            } else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown")")
                DispatchQueue.main.async { self.isLoading = false }
            }
        }.resume()
    }
    
    func fetchProfile() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/profile/\(currentUserEmail)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("❌ Profile fetch error:", error?.localizedDescription ?? "unknown")
                return
            }
            do {
                let profile = try JSONDecoder().decode(Profile.self, from: data)
                DispatchQueue.main.async {
                    self.followersCount = profile.followers.count
                    self.followingCount = profile.following.count
                }
            } catch {
                print("❌ Profile decode error:", error)
            }
        }.resume()
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            Image("person2")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                .shadow(radius: 4)

            Text(name.isEmpty ? "Unknown User" : name)
                .font(.title2)
                .fontWeight(.bold)

            Text("@\(UserDefaults.standard.string(forKey: "email") ?? "no_email")")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(bio.isEmpty ? "No bio provided" : bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 4)
    }

    private var statsSection: some View {
        HStack(spacing: 32) {
            statView(count: "\(filteredPosts.count)", label: "Posts")
            statView(count: "\(UserDefaults.standard.integer(forKey: "bals"))", label: "Points")
            statView(count: "\(followingCount)", label: "Following")
        }
    }

    private var tabSelector: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? .primary : .gray)

                    Capsule()
                        .fill(selectedTab == tab ? Color.blue : Color.clear)
                        .frame(height: 3)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var tabContent: some View {
        Group {
            if selectedTab == "Posts" {
                postsGrid
            } else if selectedTab == "Likes" {
                likesList
            }
        }
    }

    private var postsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        let itemSize = (UIScreen.main.bounds.width - 4) / 3

        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(filteredPosts) { post in
                if let url = PostService.shared.imageURL(for: post.imagePath) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                            }
                            .frame(width: itemSize, height: itemSize)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: itemSize, height: itemSize)
                                .clipped()

                        case .failure:
                            ZStack {
                                Color.red.opacity(0.2)
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                            }
                            .frame(width: itemSize, height: itemSize)

                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 2)
    }

    private var likesList: some View {
        VStack(spacing: 12) {
            ForEach(likedPostsByOthers) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    HStack {
                        Image("person1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())

                        Text("\(firstLikerEmail(post)) liked your post")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Spacer()

                        if let url = PostService.shared.imageURL(for: post.imagePath) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray.opacity(0.2)
                                        .frame(width: 36, height: 36)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipped()
                                        .cornerRadius(4)
                                case .failure:
                                    Color.red.opacity(0.2)
                                        .frame(width: 36, height: 36)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func firstLikerEmail(_ post: Post) -> String {
        if let liker = post.likes.compactMap({ $0 }).first(where: { $0 != currentUserEmail }) {
            return liker
        } else {
            return "Someone"
        }
    }

    func statView(count: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ProfileView()
}
