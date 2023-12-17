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
