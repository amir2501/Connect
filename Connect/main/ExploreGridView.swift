import SwiftUI

struct BackendUser: Codable, Identifiable, Hashable {
    var id: String { email }
    let email: String
    let password: String?
    let name: String
    let bio: String
    let bals: Int
    let followers: [String]
    let following: [String]
}

struct ExploreGridView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [BackendUser] = []
    @State private var isLoading: Bool = true
    @FocusState private var isSearchFocused: Bool
    @State private var navigateToUser: BackendUser? = nil
    @State private var selectedImage: String? = nil
    @State private var isZoomed: Bool = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    let images = (1...20).map { "explore_\($0)" }

    // NEW: Suggested + Recent
    let recentSearches = ["cats", "summer", "coding", "coffee"]
    let suggestedPeople = [
        BackendUser(
            email: "max@f1.com",
            password: "1234",
            name: "Max Verstappen",
            bio: "3x World Champion 🏆",
            bals: 1000,
            followers: [],
            following: []
        ),
        BackendUser(
            email: "leclerc@f1.com",
            password: "1234",
            name: "Charles Leclerc",
            bio: "Ferrari 🔴",
            bals: 1000,
            followers: [],
            following: []
        ),
        BackendUser(
            email: "alonso@f1.com",
            password: "1234",
            name: "Fernando Alonso",
            bio: "Legend returns 🟢",
            bals: 1000,
            followers: [],
            following: []
        ),
        BackendUser(
            email: "hamilton@f1.com",
            password: "1234",
            name: "Lewis Hamilton",
            bio: "7x World Champion 🏁",
            bals: 1000,
            followers: [],
            following: []
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search users", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($isSearchFocused)
                                .onChange(of: searchText) { _, _ in
                                    searchUsers()
                                }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // 1. Search results
                        if isSearchFocused {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    if !searchText.isEmpty {
                                        ForEach(searchResults) { user in
                                            searchResultRow(user: user)
                                        }
                                    } else {
                                        // 2. Recent searches
                                        if !recentSearches.isEmpty {
                                            Text("Recent")
                                                .font(.headline)
                                                .padding(.horizontal)

                                            ForEach(recentSearches, id: \.self) { term in
                                                Text(term)
                                                    .padding(.horizontal)
                                                    .foregroundColor(.secondary)
                                            }

                                            Divider().padding(.horizontal)
                                        }

                                        // 3. Suggested users
                                        Text("Suggested for you")
                                            .font(.headline)
                                            .padding(.horizontal)

                                        ForEach(suggestedPeople) { user in
                                            searchResultRow(user: user)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Default grid
                            GeometryReader { geometry in
                                let itemSize = (geometry.size.width - 4) / 3
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 2) {
                                        ForEach(images, id: \.self) { imageName in
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: itemSize, height: itemSize)
                                                .clipped()
                                                .onTapGesture {}
                                                .simultaneousGesture(
                                                    LongPressGesture(minimumDuration: 0.5)
                                                        .onEnded { _ in
                                                            selectedImage = imageName
                                                            isZoomed = true
                                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                        }
                                                )
                                        }
                                    }
                                    .padding(2)
                                }
                            }
                        }

                        Spacer()
                    }
                }

                // Zoom overlay
                if let image = selectedImage, isZoomed {
                    Color.black.opacity(0.9).ignoresSafeArea()

                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isZoomed = false
                            }
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLoading = false
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isZoomed)
            .navigationDestination(item: $navigateToUser) { user in
                RealUserProfileView(user: user)
            }
        }
    }

    // Row for any user (real or suggested)
    func searchResultRow(user: BackendUser) -> some View {
        Button {
            navigateToUser = user
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.body)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    // API call
func searchUsers() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }

        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/search?query=\(query)") else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data returned")
                return
            }

            // Print the raw JSON for debugging
            print("📨 Raw search response:", String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode([BackendUser].self, from: data)
                DispatchQueue.main.async {
                    searchResults = decoded
                }
            } catch {
                print("❌ Failed to decode searchUsers():", error)
            }
        }.resume()
    }
}

#Preview {
    ExploreGridView()
}
