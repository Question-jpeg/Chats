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
    var scrollPositions = [String: Int]()
    
    @Published var recentMessages = [RecentMessage]()
    
    var listener: ListenerRegistration?
    
    init() {
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
            guard let snapshot else { return }
            Task {
                let listenerRecentMessages: [ListenerRecentMessage] = await snapshot.documentChanges
                    .asyncCompactMap {
                        guard let message = try? $0.document.data(as: Message.self) else { return nil }
                        let user: User?
                        
                        if let cachedUser = recentMessages.first(where: { $0.user.id == message.partnerId }) {
                            user = cachedUser.user
                        } else {
                            user = try? await fetchUser(id: message.partnerId)
                        }
                        
                        guard let user else { return nil }
                        return ListenerRecentMessage(type: $0.type, recentMessage: RecentMessage(message: message, user: user))
                    }
                
                let newRecentMessages = listenerRecentMessages.filter { $0.type == .added }.map { $0.recentMessage }
                let modifiedRecentMessages = listenerRecentMessages.filter { $0.type == .modified }.map { $0.recentMessage }
                let deletedRecentMessages = listenerRecentMessages.filter { $0.type == .removed }.map { $0.recentMessage }
                
                withAnimation {
                    recentMessages.append(contentsOf: newRecentMessages)
                    modifiedRecentMessages.forEach { recentMessage in
                        if let index = recentMessages.firstIndex(where: { $0.user.id == recentMessage.user.id }) {
                            recentMessages[index] = recentMessage
                        }
                    }
                    deletedRecentMessages.forEach { recentMessage in
                        if let index = recentMessages.firstIndex(where: { $0.user.id == recentMessage.user.id }) {
                            recentMessages.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    func fetchUser(id: String) async throws -> User {
        try await FirebaseConstants.getUserDocRef(uuid: id).getDocument(as: User.self)
    }
}
