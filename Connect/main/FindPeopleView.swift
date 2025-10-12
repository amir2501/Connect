//
//  FindPeopleView.swift
//  Connect
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Person model
struct Person: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    var imageUrl: String?
    var color: Color

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct IndexedPerson: Identifiable {
    let id: Int
    let person: Person
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Main View
struct FindPeopleView: View {
    @State private var people: [Person] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.2995, longitude: 69.2401),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var hasCenteredOnce = false
    @StateObject private var locationManager = LocationManager()
    @State private var timer: Timer?

    private let baseURL = "https://media-storage-hackaton.onrender.com"

    // Color palette for default pins
    private let pinColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .mint, .indigo, .cyan]

    var indexedPeople: [IndexedPerson] {
        people.enumerated().map { IndexedPerson(id: $0.offset, person: $0.element) }
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: indexedPeople) { indexedPerson in
            MapAnnotation(coordinate: indexedPerson.person.location) {
                VStack(spacing: 4) {
                    if let urlString = indexedPerson.person.imageUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 3)
                            case .failure(_):
                                // ❌ If image fails to load, fallback to a colored circle
                                Circle()
                                    .fill(indexedPerson.person.color)
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            case .empty:
                                ProgressView()
                                    .frame(width: 36, height: 36)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // 👤 If no image URL, show colored circle
                        Circle()
                            .fill(indexedPerson.person.color)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }

                    Text(indexedPerson.person.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .fixedSize()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            print("🗺️ FindPeopleView appeared")
            startTimer()
            hasCenteredOnce = false
        }
        .onDisappear {
            stopTimer()
            hasCenteredOnce = false
        }
    }

    // MARK: - Timer Handling
    func startTimer() {
        fetchAndUpdate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            fetchAndUpdate()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Combine fetch & update
    func fetchAndUpdate() {
        fetchPeopleLocations()
        if let currentLocation = locationManager.lastLocation {
            updateUserLocationToServer(location: currentLocation)
        } else {
            print("⚠️ User location not yet available")
        }
    }

    // MARK: - Fetch all people locations
    func fetchPeopleLocations() {
        guard let url = URL(string: "\(baseURL)/all-locations") else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Fetch error:", error.localizedDescription)
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                struct RawPerson: Decodable {
                    let name: String
                    let locationCoords: LocationCoords?

                    struct LocationCoords: Decodable {
                        let lat: Double?
                        let lng: Double?
                    }
                }

                let rawPeople = try JSONDecoder().decode([RawPerson].self, from: data)

                let decodedPeople = rawPeople.compactMap { raw -> Person? in
                    guard let lat = raw.locationCoords?.lat,
                          let lng = raw.locationCoords?.lng else { return nil }

                    // Construct image URL per user
                    let imageUrl = "\(baseURL)/connect/profile/\(raw.name).jpg"

                    // Assign random fallback color
                    let randomColor = pinColors.randomElement() ?? .gray

                    return Person(
                        id: raw.name,
                        name: raw.name,
                        latitude: lat,
                        longitude: lng,
                        imageUrl: imageUrl,
                        color: randomColor
                    )
                }

                DispatchQueue.main.async {
                    self.people = decodedPeople
                    if !self.hasCenteredOnce, let first = self.people.first {
                        self.region.center = first.location
                        self.hasCenteredOnce = true
                    }
                }

                print("✅ Decoded \(decodedPeople.count) people:")
                for person in decodedPeople {
                    print("   👤 \(person.name), img=\(person.imageUrl ?? "❌ none")")
                }

            } catch {
                print("❌ Decoding error:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw data:", raw)
                }
            }
        }.resume()
    }

    // MARK: - Update user's location
    func updateUserLocationToServer(location: CLLocation) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("❌ User email not found in UserDefaults")
            return
        }

        guard let url = URL(string: "\(baseURL)/update-location") else {
            print("❌ Invalid update-location URL")
            return
        }

        let body: [String: Any] = [
            "email": email,
            "locationName": "Tashkent",
            "locationCoords": [
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("❌ Failed to update location:", error.localizedDescription)
            } else {
                print("✅ Location updated for \(email): \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }.resume()
    }
}

#Preview {
    FindPeopleView()
}
