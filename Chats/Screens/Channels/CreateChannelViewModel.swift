//
//  SelectGroupMembersViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 18.12.2023.
//

import SwiftUI

@MainActor
class CreateChannelViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var searchText = ""
    @Published var selectedUsers = [User]()
    @Published var channelName = ""
    @Published var channelImage: UIImage?
    @Published var isLoading = false
    
    let authModel: AuthViewModel
    
    var filteredUsers: [User] {
        let users = users.filter { user in
            user.id != FirebaseConstants.currentUserId
        }
        if searchText.isEmpty { return users }
        return users.filter { user in
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func isSelected(user: User) -> Bool {
        selectedUsers.contains(where: { $0.id == user.id })
    }
    
    func selectUser(user: User) {
        if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
    
    func deselectUser(user: User) {
        selectedUsers.removeAll(where: { $0.id == user.id })
    }
    
    init(authModel: AuthViewModel) {
        self.authModel = authModel
        fetchUsers()
    }
    
    func fetchUsers() {
        Task {
            do {
                let snapshot = try await FirebaseConstants.usersCollection.getDocuments()
                users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
            } catch {
                print("DEBUG: Failed to fetch users with error: \(error.localizedDescription)")
            }
        }
    }
    
    func createChannel(onCompletion: @escaping () -> Void = {}) {
        guard let currentUser = authModel.userSession else { return }
        
        Task {
            defer { isLoading = false }
            do {
                isLoading = true
                var uids = selectedUsers.map({ $0.id })
                uids.append(currentUser.id)
                try await FirebaseConstants.createChannel(name: channelName, uids: uids, image: channelImage, currentUser: currentUser)
                onCompletion()
            } catch {
                print("Failed to create channel due to error: \(error.localizedDescription)")
            }
        }
    }
}
