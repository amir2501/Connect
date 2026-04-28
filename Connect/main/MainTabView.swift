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
                    .scaleEffect(1.5)
            } else {
                TabView(selection: $selectedTab) {

                    NavigationStack { HomeView() }
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)

                    NavigationStack { SearchView() }
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                        .tag(1)

                    Color.clear
                        .tabItem {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                        }
                        .tag(99)
                        .onAppear { showCreatePost = true }

                    NavigationStack { FindPeopleView() }
                        .tabItem { Label("Find People", systemImage: "person.3.fill") }
                        .tag(2)

                    NavigationStack { ProfileView() }
                        .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                        .tag(3)
                }
                .tint(.figmaBlue)
                .onChange(of: selectedTab) { _ in
                    playHapticFeedback(strength: .heavy)
                }
                .sheet(isPresented: $showCreatePost, onDismiss: {
                    selectedTab = 0
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
    
//    @State private var selectedEvent = "For You"
    @State private var selectedEvent = "For You"
    @State private var activeEvent: String? = nil
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("Connect")
                        .font(.title2.bold())

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
                        // 👇EVENTS SELECTOR
                        EventsSelectorView(
                            selected: $selectedEvent,
                            onSelect: { event in
                                activeEvent = event
                            }
                        )
                        .padding(.top, 8)
                        .navigationDestination(item: $activeEvent) { event in
                            switch event {
                            case "Randomizer":
                                RandomPlacePickerView()
                            case "Fashion Week":
                                OutfitView()
                            case "Friends":
                                FindPeopleView()
                            case "Events":
                                EventsListView() // 👈 create this (simple list or placeholder)
                            case "For You":
                                ForYouView() // 👈 optional custom feed
                            default:
                                EmptyView()
                            }
                        }
                        
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


struct EventsListView: View {
    var body: some View {
        Text("Events List")
            .navigationTitle("Events")
    }
}

struct ForYouView: View {
    var body: some View {
        Text("For You Feed")
            .navigationTitle("For You")
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


extension View {
    @ViewBuilder
    func ifAvailableiOS18<Content: View>(
        _ transform: (Self) -> Content
    ) -> some View {
        if #available(iOS 18.0, *) {
            transform(self)
        } else {
            self
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
