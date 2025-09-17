//
//  PlaceData.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/20/25.
//


import SwiftUI

struct PlaceData {
    static let places: [Place] = [
        // Bakeries
        Place(name: "Bon!", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries1.png", distanceKm: 1.2, category: "Bakeries"),
        Place(name: "Paul mansion de qualite", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries2.png", distanceKm: 1.5, category: "Bakeries"),
        Place(name: "Safia", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries3.png", distanceKm: 2.0, category: "Bakeries"),
        Place(name: "Rahat", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries4.png", distanceKm: 0.9, category: "Bakeries"),
        Place(name: "Pie Republic", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries5.jpeg", distanceKm: 1.1, category: "Bakeries"),
        Place(name: "Soul artisan", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakeries6.jpeg", distanceKm: 1.6, category: "Bakeries"),
        Place(name: "Breadly bakery", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bakeries/bakery7.jpeg", distanceKm: 1.0, category: "Bakeries"),

        // Bars
        Place(name: "Q bar", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar1.jpeg", distanceKm: 2.2, category: "Bars"),
        Place(name: "Мята Bar", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar2.jpg", distanceKm: 1.8, category: "Bars"),
        Place(name: "Silk 96 wine & lounge", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar3.jpeg", distanceKm: 3.4, category: "Bars"),
        Place(name: "Tepito", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar4.jpg", distanceKm: 2.1, category: "Bars"),
        Place(name: "Just wine", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar5.jpeg", distanceKm: 2.9, category: "Bars"),
        Place(name: "Wine time", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar6.jpeg", distanceKm: 1.3, category: "Bars"),
        Place(name: "Hype", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar7.jpeg", distanceKm: 2.8, category: "Bars"),
        Place(name: "Steam", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar8.jpeg", distanceKm: 3.0, category: "Bars"),
        Place(name: "Куранты", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar9.jpeg", distanceKm: 2.4, category: "Bars"),
        Place(name: "Mad brick", imageURL: "https://amir2501.github.io/media-storage-for-connect/Bars/bar10.jpeg", distanceKm: 1.9, category: "Bars"),

        // Brunch
        Place(name: "Шале", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch1.jpeg", distanceKm: 1.5, category: "Brunch"),
        Place(name: "1991", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch2.jpeg", distanceKm: 1.7, category: "Brunch"),
        Place(name: "Actor", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch3.jpeg", distanceKm: 2.0, category: "Brunch"),
        Place(name: "Forn lebnen", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch4.jpeg", distanceKm: 2.5, category: "Brunch"),
        Place(name: "Ember & Embar", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch5.jpeg", distanceKm: 3.1, category: "Brunch"),
        Place(name: "Caravan", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch6.jpeg", distanceKm: 1.6, category: "Brunch"),
        Place(name: "Quadro", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch7.jpeg", distanceKm: 2.9, category: "Brunch"),
        Place(name: "Benedict", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch8.jpeg", distanceKm: 1.3, category: "Brunch"),
        Place(name: "Bon!", imageURL: "https://amir2501.github.io/media-storage-for-connect/Brunch/brunch9.jpeg", distanceKm: 2.2, category: "Brunch"),
        
        //cafes
        
        Place(name: "Bon!", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe1.png", distanceKm: 1.2, category: "Cafes"),
        Place(name: "Costa coffee", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe2.png", distanceKm: 1.7, category: "Cafes"),
        Place(name: "Socials", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe3.png", distanceKm: 2.5, category: "Cafes"),
        Place(name: "Giotto", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe4.png", distanceKm: 2.9, category: "Cafes"),
        Place(name: "Beanberry", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe5.png", distanceKm: 0.8, category: "Cafes"),
        Place(name: "Florya", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe6.png", distanceKm: 1.4, category: "Cafes"),
        Place(name: "Cakelab", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe7.png", distanceKm: 2.6, category: "Cafes"),
        Place(name: "Чайкоф", imageURL: "https://amir2501.github.io/media-storage-for-connect/Cafes/cafe8.png", distanceKm: 1.9, category: "Cafes"),
        
        //fastFood
        
        Place(name: "KFC", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood1.jpeg", distanceKm: 1.1, category: "Fast-Food"),
        Place(name: "Wendy’s", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood2.jpeg", distanceKm: 1.5, category: "Fast-Food"),
        Place(name: "Gosht", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood3.jpeg", distanceKm: 2.0, category: "Fast-Food"),
        Place(name: "Bellisimo pizza", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood4.jpeg", distanceKm: 2.7, category: "Fast-Food"),
        Place(name: "Max way", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood5.jpeg", distanceKm: 1.8, category: "Fast-Food"),
        Place(name: "Street 77", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood6.jpeg", distanceKm: 2.3, category: "Fast-Food"),
        Place(name: "Evos", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fast-Food/fastFood7.jpeg", distanceKm: 2.1, category: "Fast-Food"),
        
        //fine Dining
        Place(name: "Ember & Embar", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fine-Dining/fineDining1.jpeg", distanceKm: 3.0, category: "Fine-Dining"),
        Place(name: "Se7te", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fine-Dining/fineDining2.jpeg", distanceKm: 2.2, category: "Fine-Dining"),
        Place(name: "Affresco", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fine-Dining/fineDining3.jpeg", distanceKm: 2.5, category: "Fine-Dining"),
        Place(name: "Kaizen", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fine-Dining/fineDining4.jpeg", distanceKm: 3.3, category: "Fine-Dining"),
        Place(name: "Teppanyaki", imageURL: "https://amir2501.github.io/media-storage-for-connect/Fine-Dining/fineDining5.jpeg", distanceKm: 2.6, category: "Fine-Dining"),
        
        //National Meals
        
        Place(name: "Lali", imageURL: "https://amir2501.github.io/media-storage-for-connect/National-Meals/nationalMeals1.jpeg", distanceKm: 2.0, category: "National-Meals"),
        Place(name: "Besh qozon", imageURL: "https://amir2501.github.io/media-storage-for-connect/National-Meals/nationalMeals2.jpeg", distanceKm: 2.8, category: "National-Meals"),
        
        //SeaFood
        
        Place(name: "Крабоварня", imageURL: "https://amir2501.github.io/media-storage-for-connect/Seafood/seaFood1.jpeg", distanceKm: 3.2, category: "Seafood"),
        Place(name: "Ocean Basket", imageURL: "https://amir2501.github.io/media-storage-for-connect/Seafood/seaFood2.jpeg", distanceKm: 2.6, category: "Seafood"),
        Place(name: "Furusato", imageURL: "https://amir2501.github.io/media-storage-for-connect/Seafood/seaFood3.jpeg", distanceKm: 2.9, category: "Seafood"),
        Place(name: "Kaspiyka", imageURL: "https://amir2501.github.io/media-storage-for-connect/Seafood/seaFood4.jpeg", distanceKm: 2.7, category: "Seafood"),
        Place(name: "Yapona mama", imageURL: "https://amir2501.github.io/media-storage-for-connect/Seafood/seaFood5.jpeg", distanceKm: 2.3, category: "Seafood"),

        // Continue for Cafes, Fast-Food, Fine-Dining, National-Meals, Seafood, Vegan
        // Use the same pattern: name, imageURL, distance, category
    ]
}
