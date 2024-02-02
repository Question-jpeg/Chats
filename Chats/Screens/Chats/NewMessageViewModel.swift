//
//  ChatsViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 14.12.2023.
//

import Foundation

@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var searchText = ""
    
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
    
    init() {
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
}
