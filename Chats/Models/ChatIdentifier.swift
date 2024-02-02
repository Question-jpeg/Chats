//
//  ChatIdentifier.swift
//  Chats
//
//  Created by Игорь Михайлов on 31.12.2023.
//

import Foundation

struct ChatIdentifier {
    let id: String
    let isChannel: Bool
}

struct ChatInfo {
    let id: String
    let name: String
    let image: String?
    let isChannel: Bool
}
