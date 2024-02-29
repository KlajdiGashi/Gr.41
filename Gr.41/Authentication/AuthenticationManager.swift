import FirebaseFirestore
import FirebaseAuth
import Firebase
import CryptoKit


struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()

    enum AuthenticationError: Error {
        case userNotFound
    }

    private init() {}

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

   // @discardableResult
   // func getAuthenticatedUser() throws -> AuthDataResultModel {
   //     guard let user = Auth.auth().currentUser else {
   //         throw URLError(.badServerResponse)
   //     }
   //     return AuthDataResultModel(user: user)
   //  }

    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthErrorCode(.userNotFound)
        }

        try await user.sendEmailVerification()
    }

    func isEmailVerified() -> Bool {
        if let user = Auth.auth().currentUser {
            return user.isEmailVerified
        }
        return false
    }

    func updateDocumentIfExistOrCreate(_ documentPath: String, data: [String: Any]) async throws {
        let db = Firestore.firestore()

        do {
            try await db.document(documentPath).setData(data, merge: true)
        } catch {
            print("Error updating document: \(error.localizedDescription)")
        }
    }

    func updateUserInfo(name: String, email: String, phoneNumber: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()

        try await updateUserInfoInFirestore(uid: user.uid, name: name, email: email, phoneNumber: phoneNumber, password: password)

        try await user.sendEmailVerification()
    }

    
    internal func updateUserInfoInFirestore(uid: String, name: String, email: String, phoneNumber: String, password: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        var dataToUpdate: [String: Any] = [:]

        if !name.isEmpty {
            dataToUpdate["name"] = name
        }

        if !email.isEmpty {
            dataToUpdate["email"] = email
        }

        if !phoneNumber.isEmpty {
            dataToUpdate["phoneNumber"] = phoneNumber
        }

        if !password.isEmpty {
            dataToUpdate["password"] = password
        }

        do {
            try await userRef.setData(dataToUpdate, merge: true)
        } catch {
            print("Error updating document: \(error.localizedDescription)")
            throw error
        }
    }

    func updateUserPassword(newPassword: String) async throws {
        do {
            guard let user = Auth.auth().currentUser else {
                throw AuthenticationError.userNotFound
            }

            try await user.updatePassword(to: newPassword)
        } catch {
            throw error
        }
    }
    func hashPassword(password: String) throws -> String {
           do {
               let data = Data(password.utf8)
               let hash = try SHA256.hash(data: data)
               return hash.compactMap { String(format: "%02x", $0) }.joined()
           } catch {
               throw error
           }
       }
}
