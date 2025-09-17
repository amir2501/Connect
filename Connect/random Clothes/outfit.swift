//
//  outfit.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/7/25.
//
import SwiftUI

let imageSaver = ImageSaver()

struct OutfitView: View {
    @State private var selectedStyle = "Classic"
    @State private var selectedCategory = "Adult" // New: Adult / Child
    @State private var isMale = false
    @State private var outfitPhotos: [UnsplashPhoto] = []
    @State private var isLoading = false
    @State private var showFilterSheet = false
    @State private var expandedPhotoID: String? = nil
    

    let styles = ["Classic", "Sporty", "Streetwear"]
    let categories = ["Adult", "Child"]
    let accessKey = "fjy2A59m324mkfCWVK3n1--4RR5_TAX6jvU6fiqH2m4"

    var body: some View {
        VStack {
            // Title and Filter Icon
            HStack {
                Text("Outfit Suggestions")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .padding(8)
                }
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView("Loading outfits...")
                    .padding()
            } else {
                let itemWidth = UIScreen.main.bounds.width * 0.4
                let itemHeight = itemWidth * 2

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: itemWidth), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(outfitPhotos) { photo in
                            AsyncImage(url: URL(string: photo.urls.small)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: itemWidth, height: itemHeight)
                                    .clipped()
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                                    .onLongPressGesture(minimumDuration: 0.5) {
                                        if let url = URL(string: photo.urls.full),
                                           let vc = UIApplication.shared.windows.first?.rootViewController {
                                            imageSaver.saveImageUrl(from: url, in: vc)
                                        }
                                    }
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .frame(width: itemWidth, height: itemHeight)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }

            Button("🔄 Refresh Outfit") {
                fetchOutfits()
            }
            .padding()
        }
        .onAppear(perform: fetchOutfits)
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet
        }
    }

    var FilterSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select Style")
                    .font(.headline)

                Picker("Style", selection: $selectedStyle) {
                    ForEach(styles, id: \.self) { style in
                        Text(style)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("👩 Woman")
                        .foregroundColor(isMale ? .gray : .primary)
                        .fontWeight(isMale ? .regular : .bold)

                    Toggle("", isOn: $isMale)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .frame(width: 50)

                    Text("👨 Man")
                        .foregroundColor(isMale ? .primary : .gray)
                        .fontWeight(isMale ? .bold : .regular)
                }

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Spacer()
            }
            .padding()
            .navigationBarTitle("Filters", displayMode: .inline)
            .navigationBarItems(trailing:
                Button("Apply") {
                    showFilterSheet = false
                    fetchOutfits()
                }
                .fontWeight(.bold)
            )
        }
    }

    func fetchOutfits() {
        isLoading = true
        outfitPhotos = []

        // Determine season
        let month = Calendar.current.component(.month, from: Date())
        let season: String
        switch month {
        case 3...5: season = "Spring"
        case 6...8: season = "Summer"
        case 9...11: season = "Autumn"
        default: season = "Winter"
        }

        let gender = isMale ? "man" : "woman"
        let category = selectedCategory.lowercased()

        let baseQuery: String
        if selectedStyle == "Classic" {
            baseQuery = "formal business professional outfit \(gender) \(category)"
        } else {
            baseQuery = "\(selectedStyle) outfit \(gender) \(category)"
        }

        let query = "\(baseQuery) \(season)"

        let randomPage = Int.random(in: 1...50)

        guard let url = URL(string: "https://api.unsplash.com/search/photos?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(randomPage)&per_page=12&client_id=\(accessKey)") else {
            print("❌ Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode(UnsplashResponse.self, from: data)
                        outfitPhotos = decoded.results
                    } catch {
                        print("❌ JSON decode error: \(error.localizedDescription)")
                    }
                } else if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

#Preview {
    OutfitView()
}
