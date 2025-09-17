//
//  RewardItem.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/25/25.
//


import SwiftUI

struct RewardItem: Identifiable {
    let id = UUID()
    let title: String
    let cost: Int
    let imageName: String
}

struct RewardsView: View {
    let rewards: [RewardItem] = [
        RewardItem(title: "Free Coffee", cost: 100, imageName: "cup.and.saucer"),
        RewardItem(title: "Movie Ticket", cost: 300, imageName: "film"),
        RewardItem(title: "Gift Card", cost: 500, imageName: "gift"),
        RewardItem(title: "T-shirt", cost: 700, imageName: "tshirt"),
        RewardItem(title: "Headphones", cost: 1200, imageName: "headphones"),
        RewardItem(title: "Backpack", cost: 900, imageName: "bag")
    ]
    
    @State private var userBals = UserDefaults.standard.integer(forKey: "bals")
    @State private var message: String?

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 16) {
            Text("Exchange Points")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Text("You have \(userBals) points")
                .font(.headline)
                .foregroundColor(.gray)

            if let message = message {
                Text(message)
                    .foregroundColor(.blue)
                    .font(.caption)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(rewards) { reward in
                        VStack(spacing: 10) {
                            Image(systemName: reward.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)

                            Text(reward.title)
                                .font(.headline)

                            Text("\(reward.cost) pts")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button("Redeem") {
                                redeem(reward)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .background(userBals >= reward.cost ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .disabled(userBals < reward.cost)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Rewards")
    }

    func redeem(_ reward: RewardItem) {
        userBals -= reward.cost
        UserDefaults.standard.set(userBals, forKey: "bals")
        message = "You redeemed \(reward.title)!"
    }
}