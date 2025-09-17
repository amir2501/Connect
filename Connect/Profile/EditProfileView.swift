//
//  EditProfileView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 6/23/25.
//
import SwiftUI

struct EditProfileView: View {
    @Binding var name: String
    @Binding var bio: String
    @Environment(\.dismiss) var dismiss
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter name", text: $name)
                }

                Section(header: Text("Bio")) {
                    TextField("Enter bio", text: $bio)
                }

                Button("Save") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.blue)
            }

            Button(action: {
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "name")
                UserDefaults.standard.removeObject(forKey: "bals")
                isLoggedIn = false
            }) {
                Text("Log Out")
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
            }
        }
        .navigationTitle("Edit Profile")
    }
}
