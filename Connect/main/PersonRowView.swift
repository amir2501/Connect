//
//  PersonRowView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 8/11/25.
//
//
//import SwiftUI
//import MapKit
//
//struct PersonRowView: View {
//    let name: String
//    let location: CLLocationCoordinate2D
//    let isSelected: Bool
//    var onTap: () -> Void   // ✅ closure parameter
//
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(name)
//                    .font(.headline)
//                Text("\(location.latitude), \(location.longitude)")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//            if isSelected {
//                Image(systemName: "checkmark.circle.fill")
//                    .foregroundColor(.blue)
//            }
//        }
//        .padding(.vertical, 4)
//        .contentShape(Rectangle()) // makes whole row tappable
//               .onTapGesture {
//                   onTap() // trigger closure
//               }
//    }
//}
