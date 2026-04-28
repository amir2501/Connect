//
//  TabBarAppearance.swift
//  Connect
//
//  Created by MacBook Pro M3 on 12/19/25.
//


import UIKit

enum TabBarAppearance {
    static func clearBackground() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}