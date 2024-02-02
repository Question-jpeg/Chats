//
//  ChatsViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 14.12.2023.
//

import SwiftUI
import Firebase

@MainActor
class ChatsViewModel: ObservableObject {
    @Published var recentMessages = [RecentMessage]()
    
    var listener: ListenerRegistration?
    
    func onAppear() {
        fetchRecentMessages()
    }
    
    func onDisappear() {
        listener?.remove()
    }
    
    func fetchRecentMessages() {
        guard let currentUserId = FirebaseConstants.currentUserId else { return }
        
        let query = FirebaseConstants
            .getRecentMessagesCollection(ownerId: currentUserId)
            .order(by: "timestamp", descending: true)
        
        listener = query.addSnapshotListener { [self] snapshot, _ in
            guard let changes = snapshot?.documentChanges else {
                recentMessages = []
                return
            }
            Task {
                var cachedUsers: [User] = recentMessages.map { $0.user }
                let listenerRecentMessages: [ListenerRecentMessage] = await changes
                    .asyncCompactMap {
                        guard let message = try? $0.document.data(as: Message.self) else { return nil }
                        let user: User?
                        
                        if let cachedUser = cachedUsers.first(where: { $0.id == message.partnerId }) {
                            user = cachedUser
                        } else {
                            user = try? await fetchUser(id: message.partnerId)
                            if let user { cachedUsers.append(user) }
                        }
                        
                        guard let user else { return nil }
                        return ListenerRecentMessage(type: $0.type, recentMessage: RecentMessage(message: message, user: user))
                    }
                
                let newRecentMessages = listenerRecentMessages.filter { $0.type == .added }.map { $0.recentMessage }
                let modifiedRecentMessages = listenerRecentMessages.filter { $0.type == .modified }.map { $0.recentMessage }
                let deletedRecentMessages = listenerRecentMessages.filter { $0.type == .removed }.map { $0.recentMessage }
                
                var updated = recentMessages
                
                updated.append(contentsOf: newRecentMessages)
                modifiedRecentMessages.forEach { recentMessage in
                    if let index = updated.firstIndex(where: { $0.user.id == recentMessage.user.id }) {
                        updated[index] = recentMessage
                    }
                }
                deletedRecentMessages.forEach { recentMessage in
                    if let index = updated.firstIndex(where: { $0.user.id == recentMessage.user.id }) {
                        updated.remove(at: index)
                    }
                }
                
                recentMessages = updated
            }
        }
    }
    
    func fetchUser(id: String) async throws -> User {
        try await FirebaseConstants.getUserDocRef(uuid: id).getDocument(as: User.self)
    }
}
