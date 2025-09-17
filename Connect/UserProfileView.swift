//
//  UserProfileView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/15/25.
//

import SwiftUI

struct UserProfileView: View {
    let name: String
    let imageName: String
    let description: String
    
    

    @State private var selectedTab = "Posts"
    @State private var isLoading = true

    let tabs = ["Posts", "Media", "Likes"]
    let postImages = (1...12).map { "post_\($0)" }
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Profile header
                        VStack(spacing: 8) {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                .shadow(radius: 4)

                            Text(name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("@\(name.lowercased().replacingOccurrences(of: " ", with: ""))")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)

                        // Stats
                        HStack(spacing: 32) {
                            statView(count: "245", label: "Posts")
                            statView(count: "1.2M", label: "Followers")
                            statView(count: "980", label: "Following")
                        }

                        // Subscribe button
                        Button(action: {
                            // Add subscribe logic here
                        }) {
                            Text("Subscribe")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }

                        // Tabs
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

                        // Post Grid
                        GeometryReader { geometry in
                            let itemSize = (geometry.size.width - 4) / 3

                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(postImages, id: \.self) { imageName in
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: itemSize, height: itemSize)
                                        .clipped()
                                }
                            }
                        }
                        .frame(height: 400)
                    }
                    .padding(.bottom, 32)
                }
                .navigationTitle(name)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
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
    NavigationStack {
        UserProfileView(name: "Lewis Hamilton", imageName: "person2", description: "World champion")
    }
}
