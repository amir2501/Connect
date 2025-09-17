//
//  SettingsView.swift
//  Connect
//

import SwiftUI

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme
struct Theme {
    // Light (smoky white with navy accents)
    private static let lightBackground = Color(hex: "#F8F8F6")   // smoky white
    private static let lightCard       = Color(hex: "#EDEDED")   // subtle grey card
    private static let lightAccent     = Color(hex: "#1A2A44")   // rich navy
    private static let lightText       = Color(hex: "#1A2A44")   // same navy for text
    private static let lightRed        = Color(hex: "#B22222")   // muted deep red

    // Dark (old-money navy style, slightly more blue)
    private static let darkBackground  = Color(hex: "#0A192F")   // deep navy, clear blue undertone
    private static let darkCard        = Color(hex: "#112240")   // slightly lighter navy-blue for contrast
    private static let darkAccent      = Color(hex: "#E0E1DD")   // ivory accent (timeless, elegant)
    private static let darkText        = Color(hex: "#E0E1DD")   // ivory text
    private static let darkRed         = Color(hex: "#7A0010")   // muted aristocratic crimson
    
    // Adaptive colors
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkBackground : lightBackground
    }

    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkCard : lightCard
    }

    static func accent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkAccent : lightAccent
    }

    static func text(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkText : lightText
    }
    
    static func red(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkRed : lightRed
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background(colorScheme).ignoresSafeArea()

                List {
                    Section {
                        SettingsRow(
                            icon: "person.crop.circle",
                            title: "Account",
                            scheme: colorScheme,
                            destination: SimpleUserProfileView()
                        )
                        SettingsRow(
                            icon: "bell.badge",
                            title: "Notifications",
                            scheme: colorScheme,
                            destination: NotificationsView()
                        )
                        SettingsRow(
                            icon: "lock.shield",
                            title: "Security",
                            scheme: colorScheme,
                            destination: Text("Security Settings") // Placeholder
                        )
                        SettingsRow(
                            icon: "bitcoinsign.circle",
                            title: "Coins",
                            scheme: colorScheme,
                            destination: Text("Coins Settings") // Placeholder
                        )
                    }
                    .listRowBackground(Theme.card(colorScheme))

                    Section {
                        Button(role: .destructive) {
                            print("Log Out tapped")
                        } label: {
                            HStack {
                                Image(systemName: "arrow.backward.circle.fill")
                                Text("Log Out")
                            }
                            .foregroundColor(Theme.red(colorScheme))
                        }
                    }
                    .listRowBackground(Theme.card(colorScheme))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .navigationTitle("Settings")
            }
        }
    }
}
// MARK: - Row Component
struct SettingsRow<Destination: View>: View {
    let icon: String
    let title: String
    let scheme: ColorScheme
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Theme.accent(scheme))

                Text(title)
                    .foregroundColor(Theme.text(scheme))
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    Group {
        SettingsView()
            .preferredColorScheme(.dark)

//        SettingsView()
//            .preferredColorScheme(.dark)
    }
}
