//
//  RealUserProfileView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/9/25.
//
import SwiftUI

struct RealUserProfileView: View {
    let user: BackendUser

    @State private var currentUserEmail: String = UserDefaults.standard.string(forKey: "email") ?? ""
    @State private var isFollowing: Bool = false
    @State private var followersCount: Int = 0
    @State private var selectedTab = "Posts"
    @State private var isLoading = true

    let tabs = ["Posts", "Likes"]
    let postImages = (1...12).map { "post_\($0)" }

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        profileHeader
                        statsView
                        followButton
                        tabSelector
                        tabContent
                    }
                    .padding(.bottom)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Profile")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 2)
                    }
                }
            }
        }
        .onAppear {
            checkFollowingStatus()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text(user.name)
                .font(.title2)
                .fontWeight(.bold)

            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(user.bio.isEmpty ? "No bio provided" : user.bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var statsView: some View {
        HStack(spacing: 32) {
            statView(count: "12", label: "Posts")
            statView(count: "\(followersCount)", label: "Followers")
            statView(count: isFollowing ? "Following" : "Follow", label: "Status")
        }
    }

    private var followButton: some View {
        Group {
            if user.email != currentUserEmail {
                Button(action: {
                    isFollowing ? unfollowUser() : followUser()
                }) {
                    Text(isFollowing ? "Unfollow" : "Follow")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFollowing ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
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
                    withAnimation {
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
            } else {
                Text("Likes content placeholder") // replace with real likes logic if needed
            }
        }
    }

    private var postsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(postImages, id: \.self) { imageName in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            }
        }
        .padding(.horizontal, 4)
    }

    private func statView(count: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func checkFollowingStatus() {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/profile/\(user.email)") else {
            print("❌ Invalid URL for checkFollowingStatus")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(BackendUserWithFollowers.self, from: data) {
                    DispatchQueue.main.async {
                        isFollowing = decoded.followers.contains(currentUserEmail)
                        followersCount = decoded.followers.count
                        isLoading = false
                    }
                }
            }
        }.resume()
    }

    private func followUser() {
        sendFollowRequest(endpoint: "follow")
    }

    private func unfollowUser() {
        sendFollowRequest(endpoint: "unfollow")
    }

    private func sendFollowRequest(endpoint: String) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/\(endpoint)") else {
            print("❌ Invalid URL for \(endpoint)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["from": currentUserEmail, "to": user.email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            checkFollowingStatus()
        }.resume()
    }
}

struct BackendUserWithFollowers: Codable {
    let email: String
    let name: String
    let bio: String
    let followers: [String]
    let following: [String]
    let password: String?
    let bals: Int
}
