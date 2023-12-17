//
//  Message.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import Firebase

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let fromId: String
    let toId: String
    let read: Bool
    let isEdited: Bool
    let text: String
    let timestamp: Timestamp
}

extension Message {
    var isFromCurrentUser: Bool {
        fromId == FirebaseConstants.currentUserId
    }
    
    var partnerId: String {
        fromId == FirebaseConstants.currentUserId ? toId : fromId
    }
}

struct RecentMessage: Identifiable {
    let message: Message
    let user: User
    
    var id: String {
        message.id
    }
}

struct ListenerRecentMessage {
    let type: DocumentChangeType
    let recentMessage: RecentMessage
}

struct ListenerMessage {
    let type: DocumentChangeType
    let message: Message
}
