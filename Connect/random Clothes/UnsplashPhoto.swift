//
//  UnsplashPhoto.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/7/25.
//
import SwiftUI

//struct UnsplashPhoto: Codable, Identifiable {
//    let id: String
//    let urls: Urls
//
//    struct Urls: Codable {
//        let small: String
//        let full: String
//    }
//}

struct UnsplashPhoto: Identifiable, Codable, Hashable {
    let id: String
    let urls: Urls
    
    struct Urls: Codable, Hashable {
        let small: String
        let full: String
    }
}

struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}
