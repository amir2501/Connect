//
//  FindPeopleView.swift
//  Connect
//
import SwiftUI
import MapKit
import CoreLocation

// Person model
struct Person: Identifiable, Equatable, Decodable {
    let id: String      // email or name as id
    let name: String
    let latitude: Double
    let longitude: Double
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
struct IndexedPerson: Identifiable {
    let id: Int
    let person: Person
}

// Location Manager to get user location and permission
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

struct FindPeopleView: View {
    @State private var people: [Person] = []
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.2995, longitude: 69.2401), // Default Tashkent
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Track if we've already centered once
    @State private var hasCenteredOnce = false
    
    // Colors to cycle for user pins
    private let pinColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow]
    
    @StateObject private var locationManager = LocationManager()
    
    let baseURL = "https://media-storage-hackaton.onrender.com"
    
    // Timer for periodic fetch & update
    @State private var timer: Timer?
    
    var indexedPeople: [IndexedPerson] {
        people.enumerated().map { IndexedPerson(id: $0.offset, person: $0.element) }
    }
        
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: indexedPeople) { indexedPerson in
            MapAnnotation(coordinate: indexedPerson.person.location) {
                let color = pinColors[indexedPerson.id % pinColors.count]
                
                VStack(spacing: 4) {
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    Text(indexedPerson.person.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                        .fixedSize()
                }
                .shadow(radius: 3)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startTimer()
            hasCenteredOnce = false   // reset on entering
        }
        .onDisappear {
            stopTimer()
            hasCenteredOnce = false   // reset on leaving
        }
    }
    
    // Start a repeating timer to fetch & update every 5 seconds
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
    
    // Combined fetch people and update user location
    func fetchAndUpdate() {
        fetchPeople()
        if let currentLocation = locationManager.lastLocation {
            updateUserLocationToServer(location: currentLocation)
        } else {
            print("User location not yet available")
        }
    }
    
    // Fetch people from backend
    func fetchPeople() {
        guard let url = URL(string: "\(baseURL)/all-locations") else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                print("❌ Fetch error:", error ?? "Unknown error")
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
                    
                    var toPerson: Person? {
                        guard
                            let lat = locationCoords?.lat,
                            let lng = locationCoords?.lng
                        else { return nil }
                        return Person(id: name, name: name, latitude: lat, longitude: lng)
                    }
                }
                
                let rawPeople = try JSONDecoder().decode([RawPerson].self, from: data)
                let decodedPeople = rawPeople.compactMap { $0.toPerson }
                
                DispatchQueue.main.async {
                    people = decodedPeople
                    // ✅ Only center the first time
                    if !hasCenteredOnce, let first = people.first {
                        region.center = first.location
                        hasCenteredOnce = true
                    }
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }
    
    // Update user's own location to server every 5 seconds
    func updateUserLocationToServer(location: CLLocation) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("❌ User email not found in UserDefaults")
            return
        }
        
        let urlStr = "\(baseURL)/update-location"
        guard let url = URL(string: urlStr) else {
            print("❌ Invalid update-location URL")
            return
        }
        
        let body: [String: Any] = [
            "email": email,
            "locationName": "Tashkent", // or reverse geocode dynamically if you want
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
                print("❌ Failed to update location: \(error.localizedDescription)")
            } else {
                print("✅ User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }.resume()
    }
}

#Preview {
    FindPeopleView()
}
