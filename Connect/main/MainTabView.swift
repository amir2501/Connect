//
//  MainTabView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/13/25.
//
import SwiftUI
import UIKit
import Photos

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isLoading = true
    @State private var showCreatePost = false

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView()
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)

                    NavigationStack {
                        SearchView()
                    }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)

                    // Placeholder for the "+" action
                    Color.clear
                        .tabItem {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                        }
                        .tag(99) // Unique tag
                        .onAppear {
                            showCreatePost = true
                        }

                    NavigationStack {
                        FindPeopleView()
                    }
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Find People")
                    }
                    .tag(2)

                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(3)
                }
                .tint(.figmaBlue)
                .onChange(of: selectedTab) { newValue in
                    playHapticFeedback(strength: .heavy)
                }
                .sheet(isPresented: $showCreatePost, onDismiss: {
                    selectedTab = 0 // Return to Home after dismissing
                }) {
                    CreatePostView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
        }
    }
}
// MARK: - Home View with top message icon and "Connect" title

struct HomeView: View {
    @State private var posts: [Post] = []
    
    @State private var navigateToRandomPicker = false
    @State private var navigateToRewards = false
    @State private var navigateToOutfitIdeas = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Menu {
                        Button("🎲 Random Place Picker", action: {
                            navigateToRandomPicker = true
                        })

                        Button("🎁 Redeem Rewards", action: {
                            navigateToRewards = true
                        })

                        Button("🧥 Outfit Ideas", action: {
                            navigateToOutfitIdeas = true
                        })
                    } label: {
                        Label("Connect", systemImage: "chevron.down")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    NavigationLink(destination: MessageView()) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        playHapticFeedback(strength: .heavy)
                    })
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Divider()

                // Posts
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(posts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostView(post: post)
                                    .padding(.horizontal)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                playHapticFeedback(strength: .heavy)
                            })
                        }
                    }
                    .padding(.top)
                }

                Spacer()
            }
            .navigationBarHidden(true)
            .onAppear {
                PostService.shared.fetchPosts { fetchedPosts in
                    DispatchQueue.main.async {
                        self.posts = fetchedPosts
                    }
                }
            }

            // Hidden navigation triggers
            .background(
                NavigationLink("", destination: RandomPlacePickerView(), isActive: $navigateToRandomPicker)
                    .opacity(0)
            )
            .background(
                NavigationLink("", destination: RewardsView(), isActive: $navigateToRewards)
                    .opacity(0)
            )
            .background(
                NavigationLink("", destination: OutfitView(), isActive: $navigateToOutfitIdeas)
                    .opacity(0)
            )
        }
    }
}
// MARK: - Search View with Instagram-style explore grid

struct SearchView: View {
    var body: some View {
        NavigationStack {
            ExploreGridView()
                .navigationTitle("Search")
        }
    }
}

// MARK: - Haptic Feedback

func playHapticFeedback(strength: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let generator = UIImpactFeedbackGenerator(style: strength)
    generator.prepare()
    generator.impactOccurred()
}

#Preview {
    MainTabView()
}
