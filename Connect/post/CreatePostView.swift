//
//  CreatePostView.swift
//  Connect
//
//  Created by MacBook Pro M3 on 7/17/25.
//
import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isUploading = false

    private let userEmail: String = UserDefaults.standard.string(forKey: "email") ?? ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Post Title", text: $title)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                PhotosPicker(selection: $selectedImage, matching: .images) {
                    VStack {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 200)
                                Text("Select an Image")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onChange(of: selectedImage) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            imageData = data
                        }
                    }
                }

                Button(action: createPost) {
                    Text(isUploading ? "Creating..." : "Create Post")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isUploading || title.isEmpty || imageData == nil)

                Spacer()
            }
            .padding()
            .navigationTitle("Create Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func createPost() {
        guard let imageData else { return }
        isUploading = true

        // Upload image
        uploadImage(email: userEmail, imageData: imageData) { result in
            switch result {
            case .success(let imagePath):
                sendCreatePostRequest(title: title, imagePath: imagePath, creatorEmail: userEmail)
            case .failure(let error):
                print("❌ Upload failed:", error)
                isUploading = false
            }
        }
    }

    private func uploadImage(email: String, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/upload") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n")
        body.append("\(email)\r\n")

        let filename = "\(UUID().uuidString).jpg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode(ImageUploadResponse.self, from: data)
            else {
                completion(.failure(NSError(domain: "Invalid upload response", code: 0)))
                return
            }

            completion(.success(response.imagePath))
        }.resume()
    }

    private func sendCreatePostRequest(title: String, imagePath: String, creatorEmail: String) {
        guard let url = URL(string: "https://media-storage-hackaton.onrender.com/connect/posts/create") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "title": title,
            "imagePath": imagePath,
            "creatorEmail": creatorEmail
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                if error == nil {
                    dismiss()
                } else {
                    print("❌ Post creation failed:", error?.localizedDescription ?? "Unknown error")
                }
            }
        }.resume()
    }
}

struct ImageUploadResponse: Codable {
    let message: String
    let imagePath: String
}

// Helper for appending data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
