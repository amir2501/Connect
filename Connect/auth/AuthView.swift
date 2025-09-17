import SwiftUI

struct AuthView: View {
    let authType: AuthType
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(authType == .login ? "Login" : "Register")
                .font(.largeTitle)
                .bold()

            if authType == .register {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
            }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: submit) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(authType == .login ? "Login" : "Register")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
        }
        .padding()
    }

    func submit() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        let urlString = "https://media-storage-hackaton.onrender.com/\(authType == .login ? "login" : "register")"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var body: [String: Any] = [
            "email": email,
            "password": password,
            "type": 2
        ]

        if authType == .register {
            body["name"] = name
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    errorMessage = "No response from server"
                    return
                }

                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "nil")")

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = json["user"] as? [String: Any] {
                    UserDefaults.standard.set(user["email"] as? String, forKey: "email")
                    UserDefaults.standard.set(user["name"] as? String, forKey: "name")
                    UserDefaults.standard.set(user["bals"] as? Int ?? 0, forKey: "bals")
                    isLoggedIn = true
                } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = json["error"] as? String {
                    errorMessage = error
                } else {
                    errorMessage = "Unexpected error"
                }
            }
        }.resume()
    }
}
