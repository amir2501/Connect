import SwiftUI
import PhotosUI

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
    
    // Image picker states
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var profileImageURL: URL?

    // Upload state + logging message
    @State private var uploadInProgress = false
    @State private var uploadLog: String?

    var currentUserEmail: String {
        UserDefaults.standard.string(forKey: "email") ?? "unknown@demo.com"
    }
    let baseURL = "https://media-storage-hackaton.onrender.com"

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
                            
                            // optional small area for upload logs (helpful during debugging)
                            if let log = uploadLog {
                                Text(log)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.bottom, 32)
                        .padding(.top, 8)
                    }
                }
            }
            .onAppear {
                name = UserDefaults.standard.string(forKey: "name") ?? ""
                bio = UserDefaults.standard.string(forKey: "bio") ?? ""
                fetchPosts()
                fetchProfile()
                loadProfilePhoto()
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
        // PhotosPicker
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            // New item selected from PhotosPicker
            guard let item = newItem else {
                print("🟡 PhotosPicker: selection cleared")
                return
            }
            print("📸 PhotosPicker: item selected — loading data...")
            uploadLog = "PhotosPicker: item selected — loading data..."
            Task {
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        print("📦 PhotosPicker: data loaded (\(data.count) bytes)")
                        uploadLog = "PhotosPicker: data loaded (\(data.count) bytes)"
                        if let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                selectedImage = uiImage
                                // show local preview immediately
                                profileImageURL = nil
                                uploadLog = "Local image created — \(Int(uiImage.size.width)) x \(Int(uiImage.size.height))"
                                print("🖼️ Created UIImage size: \(Int(uiImage.size.width))x\(Int(uiImage.size.height))")
                            }
                        } else {
                            print("❌ PhotosPicker: failed to create UIImage from data")
                            uploadLog = "Failed to create UIImage from selected data"
                        }
                    } else {
                        print("❌ PhotosPicker: no data returned from selected item")
                        uploadLog = "No data returned from selected item"
                    }
                } catch {
                    print("❌ PhotosPicker load error: \(error)")
                    uploadLog = "PhotosPicker load error: \(error)"
                }
            }
        }
    }

    private func fetchPosts() {
        guard let url = URL(string: "\(baseURL)/connect/posts") else { return }

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
                    
                    print(decodedPosts)
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
        guard let url = URL(string: "\(baseURL)/connect/profile/\(currentUserEmail)") else { return }
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

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                // If user selected a local image, show it immediately
                if let local = selectedImage {
                    Image(uiImage: local)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        .shadow(radius: 4)
                }
                // otherwise show remote image if URL present
                else if let url = profileImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 100, height: 100)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                .shadow(radius: 4)
                        case .failure:
                            Image("person2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("person2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                        .shadow(radius: 4)
                }
            }
            .onTapGesture(count: 2) {
                print("🖱️ Profile image double-tapped -> opening picker")
                uploadLog = "Opening photo picker..."
                showImagePicker = true
            }
            
            // Buttons placed to the right side when a local image is selected
            if selectedImage != nil {
                HStack(spacing: 20) {
                    if uploadInProgress {
                        ProgressView()
                            .scaleEffect(0.9)
                    }

                    Button("Done") {
                        Task {
                            if let img = selectedImage {
                                await uploadProfilePhoto(img)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(uploadInProgress)

                    Button("Cancel") {
                        print("✖️ Cancelled")
                        uploadLog = "Cancelled"
                        selectedItem = nil
                        selectedImage = nil
                    }
                    .buttonStyle(.bordered)
                    .disabled(uploadInProgress)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }

            Text(name.isEmpty ? "Unknown User" : name)
                .font(.title2)
                .fontWeight(.bold)

            Text("@\(currentUserEmail)")
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
                    NavigationLink(destination: PostDetailView(post: post)) {
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
                    .buttonStyle(.plain) // removes default blue link highlight
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
                        // --- Get the first liker’s email (not the current user)
                        if let likerEmail = post.likes.compactMap({ $0 }).first(where: { $0 != currentUserEmail }) {
                            
                            // Try to build their profile photo URL
                            let profileURL = URL(string: "https://media-storage-hackaton.onrender.com/connect/profile/\(likerEmail).jpg")
                            
                            AsyncImage(url: profileURL) { phase in
                                switch phase {
                                case .empty:
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                case .failure:
                                    Image("person1")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            // --- If no liker found (shouldn’t usually happen)
                            Image("person1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        }

                        // --- Liker text ---
                        Text("\(firstLikerEmail(post)) liked your post")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Spacer()

                        // --- Post thumbnail (same as before)
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
    
    // MARK: - Upload Image
    private func uploadProfilePhoto(_ image: UIImage) async {
        await MainActor.run {
            uploadInProgress = true
            uploadLog = "Preparing upload..."
        }
        print("🔼 Starting upload for \(currentUserEmail)")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Could not convert UIImage to JPEG data")
            await MainActor.run { uploadInProgress = false; uploadLog = "Could not convert image to JPEG" }
            return
        }
        print("📏 Image data size: \(imageData.count) bytes")
        await MainActor.run { uploadLog = "Image data: \(imageData.count) bytes" }

        let boundary = "Boundary-\(UUID().uuidString)"
        guard let url = URL(string: "\(baseURL)/connect/profile/upload") else {
            print("❌ Invalid upload URL")
            await MainActor.run { uploadInProgress = false; uploadLog = "Invalid upload URL" }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build multipart body
        var body = Data()

        // email field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(currentUserEmail)\r\n".data(using: .utf8)!)

        // image file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        print("📦 Multipart body size: \(body.count) bytes")
        await MainActor.run { uploadLog = "Multipart body size: \(body.count) bytes" }

        do {
            print("⬆️ Uploading to \(url.absoluteString)...")
            await MainActor.run { uploadLog = "Uploading..." }
            let (data, response) = try await URLSession.shared.upload(for: request, from: body)

            if let httpResp = response as? HTTPURLResponse {
                print("⬆️ Upload finished — status code: \(httpResp.statusCode)")
                await MainActor.run { uploadLog = "Upload finished — status: \(httpResp.statusCode)" }
            } else {
                print("⬆️ Upload finished — no HTTPURLResponse")
                await MainActor.run { uploadLog = "Upload finished — no HTTPURLResponse" }
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📬 Server response: \(responseString)")
                await MainActor.run { uploadLog = "Server: \(responseString)" }
            } else {
                print("📬 Server response: <non-textual or empty>")
                await MainActor.run { uploadLog = "Server response empty or non-text" }
            }

            if let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 {
                // success: clear local selection and reload remote image
                print("✅ Profile photo uploaded successfully")
                await MainActor.run {
                    selectedItem = nil
                    selectedImage = nil
                    loadProfilePhoto()
                    uploadInProgress = false
//                    uploadLog = "Upload successful"
                }
            } else {
                print("❌ Upload failed (non-200)")
                await MainActor.run {
                    uploadInProgress = false
                    uploadLog = "Upload failed"
                }
            }
        } catch {
            print("❌ Upload error: \(error)")
            await MainActor.run {
                uploadInProgress = false
                uploadLog = "Upload error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Load Image
    private func loadProfilePhoto() {
        let email = currentUserEmail
        guard let url = URL(string: "\(baseURL)/connect/profile/\(email).jpg") else { return }
        print("🔽 Loading remote profile photo from: \(url.absoluteString)")
//        uploadLog = "Loading remote profile photo..."
        profileImageURL = url
    }
}

#Preview {
    ProfileView()
}
