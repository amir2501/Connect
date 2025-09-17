//
//  OutfitItem.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/7/25.
//
import SwiftUI

struct OutfitItem: Identifiable {
    let id = UUID()
    let category: String
    let name: String
    let image: String
    let style: String // "Classic", "Sporty", etc.
    let minTemp: Int
    let maxTemp: Int
}

let outfitDatabase: [OutfitItem] = [
    OutfitItem(category: "Top", name: "White Shirt", image: "tshirt", style: "Classic", minTemp: 15, maxTemp: 35),
    OutfitItem(category: "Bottom", name: "Chinos", image: "pants", style: "Classic", minTemp: 10, maxTemp: 30),
    OutfitItem(category: "Shoes", name: "Oxford Shoes", image: "shoe.fill", style: "Classic", minTemp: 0, maxTemp: 40),
    OutfitItem(category: "Accessories", name: "Leather Watch", image: "clock", style: "Classic", minTemp: -10, maxTemp: 40),
    
    OutfitItem(category: "Top", name: "Sports Tee", image: "tshirt", style: "Sporty", minTemp: 20, maxTemp: 35),
    OutfitItem(category: "Bottom", name: "Shorts", image: "shorts", style: "Sporty", minTemp: 22, maxTemp: 40),
    OutfitItem(category: "Shoes", name: "Running Shoes", image: "shoe.fill", style: "Sporty", minTemp: 0, maxTemp: 40),
    OutfitItem(category: "Accessories", name: "Smart Band", image: "watchface.applewatch.case", style: "Sporty", minTemp: -10, maxTemp: 40),
    
    OutfitItem(category: "Top", name: "Oversized Hoodie", image: "hoodie", style: "Streetwear", minTemp: 10, maxTemp: 20),
    OutfitItem(category: "Bottom", name: "Baggy Jeans", image: "pants", style: "Streetwear", minTemp: 10, maxTemp: 30),
    OutfitItem(category: "Shoes", name: "Sneakers", image: "shoe.fill", style: "Streetwear", minTemp: 5, maxTemp: 35),
    OutfitItem(category: "Accessories", name: "Chain Necklace", image: "link", style: "Streetwear", minTemp: -10, maxTemp: 40),
]
