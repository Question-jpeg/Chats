//
//  AuthViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 13.12.2023.
//

import SwiftUI

enum Field: Hashable {
    case email, username, fullName, password
}

@MainActor
class AuthViewModel: ObservableObject {    
    @Published var editableUser = EditableUser()
    @Published var password = ""
    @Published var image: UIImage?
    private var currentImage: UIImage?
    
    @Published var isUpdateLoading = false
    @Published var isUserSessionLoading = true
    @Published var userSession: User?
    
    @Published var hasImageChanged = false
    
    var hasChanges: Bool {
        guard let userSession else { return false }
        return hasImageChanged ||
        editableUser.fullName != userSession.fullName ||
        editableUser.status != userSession.status
    }
    
    init() {
        fetchCurrentUser()
    }
    
    private func setUserSession(id: String) async throws {
        let user = try await FirebaseConstants.getUserDocRef(uuid: id).getDocument(as: User.self)
        userSession = user
        
        editableUser = EditableUser(email: user.email, username: user.username, fullName: user.fullName, status: user.status)

        await setUserImage(urlString: user.profileImage)
    }
    
    private func setUserImage(urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        guard let (imageData, _) = try? await URLSession.shared.data(from: url) else { return }
        image = UIImage(data: imageData)
        currentImage = image
    }
    
    private func fetchCurrentUser() {
        Task {
            defer { isUserSessionLoading = false }            
            do {
                guard let userId = FirebaseConstants.currentUserId else { return }
                try await setUserSession(id: userId)
            } catch {
                print("DEBUG: Failed to fetch currentUser with error: \(error.localizedDescription)")
            }
        }
    }
    
    func login() {
        Task {
            defer { isUserSessionLoading = false }
            do {
                isUserSessionLoading = true
                let result = try await FirebaseConstants.auth.signIn(withEmail: editableUser.email, password: password)
                try await setUserSession(id: result.user.uid)
            } catch {
                print("DEBUG: Failed to login with error: \(error.localizedDescription)")
            }
        }
    }
    
    func register() {
        Task {
            defer { isUserSessionLoading = false }
            do {
                isUserSessionLoading = true
                guard !editableUser.username.isEmpty else { throw RegisterError.emptyUsername}
                guard !editableUser.fullName.isEmpty else { throw RegisterError.emptyFullName }
                guard let image else { throw RegisterError.emptyProfileImage }
                
                let result = try await FirebaseConstants.auth.createUser(withEmail: editableUser.email, password: password)
                
                let profileImageUrl = try await FirebaseConstants.uploadImage(id: result.user.uid, image: image)
                
                let user = User(
                    id: result.user.uid,
                    email: editableUser.email,
                    username: editableUser.username,
                    fullName: editableUser.fullName,
                    profileImage: profileImageUrl,
                    status: editableUser.status
                )
                userSession = user
                currentImage = image
                
                let userData = try FirebaseConstants.encode(user)
                
                try await FirebaseConstants.getUserDocRef(uuid: user.id).setData(userData)
            } catch {
                print("DEBUG: Failed to register with error: \(error.localizedDescription)")
            }
        }
    }
    
    func update() {
        Task {
            defer {
                isUpdateLoading = false
                hasImageChanged = false
            }
            do {
                isUpdateLoading = true
                guard let userSession else { return }
                
                var profileImageUrl: String? = nil
                if hasImageChanged {
                    guard let image else { return }
                    profileImageUrl = try await FirebaseConstants.uploadImage(id: userSession.id, image: image)
                }
                
                let uploadableUser = User(
                    id: userSession.id,
                    email: userSession.email,
                    username: userSession.username,
                    fullName: editableUser.fullName,
                    profileImage: profileImageUrl ?? userSession.profileImage,
                    status: editableUser.status
                )
                
                let data = try FirebaseConstants.encode(uploadableUser)
                
                try await FirebaseConstants.getUserDocRef(uuid: userSession.id).setData(data)
                
                try await setUserSession(id: userSession.id)
            } catch {
                print("DEBUG: Failed to update user with error: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelUpdate() {
        guard let userSession else { return }
        
        image = currentImage
        hasImageChanged = false
        editableUser.fullName = userSession.fullName
        editableUser.status = userSession.status
    }
    
    func logout() {
        userSession = nil
        
        editableUser = EditableUser()
        password = ""
        image = nil
        
        try? FirebaseConstants.auth.signOut()
    }
}
