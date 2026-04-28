//
//  EventsSelectorView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 4/27/26.
//
import SwiftUI

struct EventsSelectorView: View {
    @Binding var selected: String
    var onSelect: (String) -> Void
    
    let events: [EventCategory] = [
        .init(title: "For You", icon: "sparkles"),
        .init(title: "Events", icon: "calendar"),
        .init(title: "Randomizer", icon: "shuffle"),
        .init(title: "Fashion Week", icon: "tshirt"),
        .init(title: "Friends", icon: "person.2.fill")
    ]
    
    var body: some View {
        GeometryReader { geo in
            let maxWidth = min(geo.size.width, 600)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(events) { event in
                        EventButton(
                            title: event.title,
                            icon: event.icon,
                            isSelected: selected == event.title
                        ) {
                            selected = event.title
                            onSelect(event.title) // ✅ trigger navigation
                        }
                        .frame(width: maxWidth / 3.5)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: 80)
    }
}

struct EventButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            playHapticFeedback(strength: .light)
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .scaleEffect(isSelected ? 1.05 : 1.0) // 👈 nice touch
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}
