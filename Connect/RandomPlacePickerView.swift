////
////  RandomPlacePickerView.swift
////  Connect
////
////  Created by MacBook Pro M3 on 6/20/25.
////
//
//import SwiftUI
//
//struct Place: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let imageURL: String
//    let distanceKm: Double
//}
//
//struct RandomPlacePickerView: View {
//    let places: [Place]
//
//    @State private var numberOfPlaces = 3
//    @State private var selectedPlace: Place? = nil
//    @State private var groupedPlaces: [[Place]] = []
//    @State private var currentGroupIndex = 0
//    @State private var animatedIndices: Set<Int> = []
//    @State private var showUI = true
//    @State private var showResult = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            if showUI {
//                Text("❓")
//                    .font(.system(size: 80))
//                    .transition(.opacity)
//
//                Stepper("Number of restaurants: \(numberOfPlaces)", value: $numberOfPlaces, in: 3...min(10, places.count))
//                    .padding(.horizontal)
//
//                Button("Randomize") {
//                    var shuffled = Array(places.shuffled().prefix(numberOfPlaces))
//                    selectedPlace = shuffled.randomElement()
//                    if let selected = selectedPlace, !shuffled.contains(selected) {
//                        shuffled.removeLast()
//                        shuffled.append(selected)
//                    }
//                    groupedPlaces = splitIntoGroups(places: shuffled, maxPerGroup: 4)
//                    currentGroupIndex = 0
//                    animatedIndices = []
//                    showResult = false
//                    withAnimation {
//                        showUI = false
//                    }
//                    animateGroupSequentially()
//                }
//                .buttonStyle(.borderedProminent)
//            }
//
//            if !showUI && !showResult && currentGroupIndex < groupedPlaces.count {
//                let currentGroup = groupedPlaces[currentGroupIndex]
//
//                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                    ForEach(Array(currentGroup.enumerated()), id: \.element.id) { index, place in
//                        let offset = cardOffset(for: index, count: currentGroup.count)
//                        let isAnimated = animatedIndices.contains(index)
//
//                        VStack {
//                            AsyncImage(url: URL(string: place.imageURL)) { image in
//                                image.resizable()
//                                     .scaledToFill()
//                            } placeholder: {
//                                Color.gray.opacity(0.2)
//                            }
//                            .frame(width: 120, height: 120)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//
//                            Text(place.name)
//                                .font(.headline)
//
//                            Text(String(format: "%.1f km away", place.distanceKm))
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//                        .opacity(isAnimated ? 1 : 0)
//                        .offset(x: isAnimated ? 0 : offset.x, y: isAnimated ? 0 : offset.y)
//                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.3), value: animatedIndices)
//                    }
//                }
//                .padding(.horizontal)
//
//                Text("\(currentGroupIndex + 1)/\(groupedPlaces.count)")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                    .padding(.top, 6)
//            }
//
//            if showResult, let chosen = selectedPlace {
//                VStack(spacing: 20) {
//                    AsyncImage(url: URL(string: chosen.imageURL)) { image in
//                        image.resizable()
//                             .scaledToFill()
//                    } placeholder: {
//                        Color.gray.opacity(0.2)
//                    }
//                    .frame(width: 150, height: 150)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//
//                    Text(chosen.name)
//                        .font(.title2)
//                        .bold()
//
//                    Text(String(format: "%.1f km away", chosen.distanceKm))
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//
//                    Button("Again") {
//                        withAnimation {
//                            showUI = true
//                            showResult = false
//                            selectedPlace = nil
//                            groupedPlaces = []
//                            currentGroupIndex = 0
//                            animatedIndices = []
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//
//    func cardOffset(for index: Int, count: Int) -> (x: CGFloat, y: CGFloat) {
//        let middleIndex = count / 2
//        if count % 2 != 0 && index == middleIndex {
//            return (0, 300)
//        } else if index < middleIndex {
//            return (-300, 0)
//        } else {
//            return (300, 0)
//        }
//    }
//
//    func splitIntoGroups(places: [Place], maxPerGroup: Int) -> [[Place]] {
//        var groups: [[Place]] = []
//        var start = 0
//        while start < places.count {
//            let remaining = places.count - start
//            let groupSize = min(remaining, maxPerGroup)
//            groups.append(Array(places[start..<start+groupSize]))
//            start += groupSize
//        }
//        return groups
//    }
//
//    func animateGroupSequentially() {
//        let group = groupedPlaces[currentGroupIndex]
//        for i in 0..<group.count {
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
//                animatedIndices.insert(i)
//
//                if i == group.count - 1 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        if currentGroupIndex < groupedPlaces.count - 1 {
//                            currentGroupIndex += 1
//                            animatedIndices = []
//                            animateGroupSequentially()
//                        } else {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                withAnimation {
//                                    groupedPlaces = []
//                                    showResult = true
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
