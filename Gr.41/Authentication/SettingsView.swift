import SwiftUI
import FirebaseAuth
import CryptoKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var name = ""
    @Published var phonenumber = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmpassword = ""

    func saveChanges(name: String, email: String, phoneNumber: String, password: String, confirmPassword: String) async throws {
        guard password == confirmPassword else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
        }

        do {
            guard let user = Auth.auth().currentUser else {
                throw URLError(.badServerResponse)
            }

            let hashedPassword = try await AuthenticationManager.shared.hashPassword(password: password)

            try await AuthenticationManager.shared.updateUserInfo(name: name, email: email, phoneNumber: phoneNumber, password: password)

            try await AuthenticationManager.shared.updateUserPassword(newPassword: password)

            try await updateFirestoreUserInfo(uid: user.uid, name: name, email: email, phoneNumber: phoneNumber)

        } catch {
            throw error
        }
    }

    func signOut() async throws {
        do {
            try await AuthenticationManager.shared.signOut()
        } catch {
            throw error
        }
    }

    private func updateFirestoreUserInfo(uid: String, name: String, email: String, phoneNumber: String) async throws {
        do {
            guard let user = Auth.auth().currentUser else {
                throw URLError(.badServerResponse)
            }
            try await AuthenticationManager.shared.updateUserInfoInFirestore(uid: user.uid, name: name, email: email, phoneNumber: phoneNumber, password: password)
        } catch {
            print("Error updating Firestore user info: \(error)")
            throw error
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var name: String = ""
    @State private var confirmEmail: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Binding var showSigningView: Bool
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .autocapitalization(.none)
                .textCase(.none)
                .padding()
                .font(.system(size: 22))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("Phone Number", text: $phoneNumber)
                .autocapitalization(.none)
                .textCase(.none)
                .padding()
                .font(.system(size: 22))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textCase(.none)
                .padding()
                .font(.system(size: 22))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            TextField("Confirm Email", text: $confirmEmail)
                .autocapitalization(.none)
                .textCase(.none)
                .padding()
                .font(.system(size: 22))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField("Password", text: $viewModel.password)
                        .autocapitalization(.none)
                        .padding()
                        .font(.system(size: 20))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 23)
                            }
                            .padding(.leading, 8),
                            alignment: .trailing
                        )
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .autocapitalization(.none)
                        .padding()
                        .font(.system(size: 20))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.slash.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 23)
                            }
                            .padding(.leading, 8),
                            alignment: .trailing
                        )
                }
            }

            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField("Confrim Password", text: $viewModel.confirmpassword)
                        .autocapitalization(.none)
                        .padding()
                        .font(.system(size: 20))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 23)
                            }
                            .padding(.leading, 8),
                            alignment: .trailing
                        )
                } else {
                    SecureField("Confirm Password", text: $viewModel.confirmpassword)
                        .autocapitalization(.none)
                        .padding()
                        .font(.system(size: 20))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .overlay(
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: "eye.slash.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 23)
                            }
                            .padding(.leading, 8),
                            alignment: .trailing
                        )
                }
            }

            HStack {
                Button {
                    Task {
                        do {
                            try await viewModel.saveChanges(name: name, email: email, phoneNumber: phoneNumber, password: password, confirmPassword: confirmPassword)
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Save Changes")
                        .textCase(.none)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                }

                Button {
                    Task {
                        do {
                            try await viewModel.signOut()
                            DispatchQueue.main.async {
                                showSigningView = true
                            }
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Log Out")
                        .textCase(.none)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }

            NavigationLink(destination: ResetPasswordView()) {
                Text("Reset Password")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSigningView: .constant(false))
        }
    }
}
