//
//  Channel.swift
//  Chats
//
//  Created by Игорь Михайлов on 30.12.2023.
//

import Firebase

struct Channel: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let uids: [String]
    let lastMessage: UserMessage
    let image: String?
}

struct LastMessageUpdateData: Codable {
    let lastMessage: UserMessage
}

struct ListenerChannel {
    let type: DocumentChangeType
    let channel: Channel
}
