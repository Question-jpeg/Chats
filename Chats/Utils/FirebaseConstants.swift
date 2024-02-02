//
//  FirestoreConstants.swift
//  Chats
//
//  Created by Игорь Михайлов on 13.12.2023.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct FirebaseConstants {
    static let firestore = Firestore.firestore()
    static let storage = Storage.storage()
    static let encoder = Firestore.Encoder()
    static let auth = Auth.auth()
    
    static let usersCollection = firestore.collection("users")
    static let messagesCollection = firestore.collection("messages")
    static let channelsCollection = firestore.collection("channels")
    
    static var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    static func encode(_ value: Encodable) throws -> [String: Any] {
        try encoder.encode(value)
    }
}

extension FirebaseConstants {
    static func sendMessage(_ text: String, toUserId: String) async throws {
        guard let currentUserId else { return }
        
        let userMessageRef = FirebaseConstants.getMessageDocRef(
            ownerId: currentUserId,
            toId: toUserId
        )
        
        let partnerMessageRef = FirebaseConstants.getMessageDocRef(
            ownerId: toUserId,
            toId: currentUserId,
            documentId: userMessageRef.documentID
        )
        
        let recentUserMessageRef = getRecentMessageDocRef(ownerId: currentUserId, partnerId: toUserId)
        let recentPartnerMessageRef = getRecentMessageDocRef(ownerId: toUserId, partnerId: currentUserId)
        
        let data = try FirebaseConstants.encode(
            Message(
                id: userMessageRef.documentID,
                fromId: currentUserId,
                toId: toUserId,
                read: false,
                isEdited: false,
                text: text,
                timestamp: Timestamp(date: Date())
            )
        )
        let batch = firestore.batch()
        
        batch.setData(data, forDocument: userMessageRef)
        batch.setData(data, forDocument: partnerMessageRef)
        batch.setData(data, forDocument: recentUserMessageRef)
        batch.setData(data, forDocument: recentPartnerMessageRef)
        
        try await batch.commit()
    }
    
    static func editMessage(_ text: String, message: Message, recentMessageId: String) async throws {
        guard let currentUserId else { return }
        guard text != message.text else { return }
        
        let data = try encode(Message(
            id: message.id,
            fromId: message.fromId,
            toId: message.toId,
            read: message.read,
            isEdited: true,
            text: text,
            timestamp: message.timestamp)
        )
        let batch = firestore.batch()
        
        if recentMessageId == message.id {
            batch.setData(data, forDocument: getRecentMessageDocRef(ownerId: currentUserId, partnerId: message.partnerId))
            batch.setData(data, forDocument: getRecentMessageDocRef(ownerId: message.partnerId, partnerId: currentUserId))
        }
        
        batch.setData(data, forDocument: getMessageDocRef(ownerId: currentUserId, toId: message.partnerId, documentId: message.id))
        batch.setData(data, forDocument: getMessageDocRef(ownerId: message.partnerId, toId: currentUserId, documentId: message.id))

        try await batch.commit()
    }
    
    static func deleteMessage(message: Message, recentMessageId: String, newRecentMessage: Message?) async throws {
        guard let currentUserId else { return }
        
        let batch = firestore.batch()
        
        if recentMessageId == message.id {
            let recentUserMessageDocRef = getRecentMessageDocRef(ownerId: currentUserId, partnerId: message.partnerId)
            let recentPartnerMessageDocRef = getRecentMessageDocRef(ownerId: message.partnerId, partnerId: currentUserId)
            
            if newRecentMessage == nil {
                batch.deleteDocument(recentUserMessageDocRef)
                batch.deleteDocument(recentPartnerMessageDocRef)
            } else {
                let data = try encode(newRecentMessage)
                batch.setData(data, forDocument: recentUserMessageDocRef)
                batch.setData(data, forDocument: recentPartnerMessageDocRef)
            }
        }
        
        batch.deleteDocument(getMessageDocRef(ownerId: currentUserId, toId: message.partnerId, documentId: message.id))
        batch.deleteDocument(getMessageDocRef(ownerId: message.partnerId, toId: currentUserId, documentId: message.id))
    
        try await batch.commit()
    }
    
    static func deleteMessages(messages: [Message], recentMessageId: String, newRecentMessage: Message?) async throws {
        guard let currentUserId else { return }
        
        let batch = firestore.batch()
        
        if messages.contains(where: { $0.id == recentMessageId }) {
            let recentUserMessageDocRef = getRecentMessageDocRef(ownerId: currentUserId, partnerId: messages[0].partnerId)
            let recentPartnerMessageDocRef = getRecentMessageDocRef(ownerId: messages[0].partnerId, partnerId: currentUserId)
            
            if newRecentMessage == nil {
                batch.deleteDocument(recentUserMessageDocRef)
                batch.deleteDocument(recentPartnerMessageDocRef)
            } else {
                let data = try encode(newRecentMessage)
                batch.setData(data, forDocument: recentUserMessageDocRef)
                batch.setData(data, forDocument: recentPartnerMessageDocRef)
            }
        }
        
        messages.forEach { message in
            batch.deleteDocument(getMessageDocRef(ownerId: currentUserId, toId: message.partnerId, documentId: message.id))
            batch.deleteDocument(getMessageDocRef(ownerId: message.partnerId, toId: currentUserId, documentId: message.id))
        }
        
        try await batch.commit()
    }
}

extension FirebaseConstants {
    static func createChannel(name: String, uids: [String], image: UIImage?, currentUser: User) async throws {
        let channelDocRef = FirebaseConstants.getChannelDocRef()
        var imageUrl: String? = nil
        if let image {
            imageUrl = try await FirebaseConstants.uploadImage(id: channelDocRef.documentID, image: image)
        }
        let message = Message(
            id: UUID().uuidString,
            fromId: currentUser.id,
            toId: channelDocRef.documentID,
            read: false,
            isEdited: false,
            text: "created the channel",
            timestamp: Timestamp(date: Date())
        )
        let data = try FirebaseConstants.encode(
            Channel(
                id: channelDocRef.documentID,
                name: name,
                uids: uids,
                lastMessage: UserMessage(message: message, user: currentUser),
                image: imageUrl
            )
        )
        
        try await channelDocRef.setData(data)
    }
    
    static func sendChannelMessage(messageText: String, channelId: String, currentUser: User) async throws {
        let messageDocRef = getChannelMessageDocRef(channelId: channelId)
        let channelDocRef = getChannelDocRef(documentId: channelId)
        let message = Message(
            id: messageDocRef.documentID,
            fromId: currentUser.id,
            toId: channelId,
            read: false,
            isEdited: false,
            text: messageText,
            timestamp: Timestamp(date: Date())
        )
        let data = try encode(message)
        let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: message, user: currentUser)))
        
        let batch = firestore.batch()
        
        batch.setData(data, forDocument: messageDocRef)
        batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
        
        try await batch.commit()
    }
    
    static func editChannelMessage(_ messageText: String, message: Message, lastMessageId: String, currentUser: User) async throws {
        guard messageText != message.text else { return }
        let channelDocRef = getChannelDocRef(documentId: message.toId)
        let messageDocRef = getChannelMessageDocRef(channelId: message.toId, documentId: message.id)
        let data = try encode(Message(
            id: message.id,
            fromId: message.fromId,
            toId: message.toId,
            read: message.read,
            isEdited: true,
            text: messageText,
            timestamp: message.timestamp)
        )
        let batch = firestore.batch()
        
        if lastMessageId == message.id {
            let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: message, user: currentUser)))
            batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
        }
        
        batch.setData(data, forDocument: messageDocRef)

        try await batch.commit()
    }
    
    static func deleteChannelMessage(message: Message, lastMessageId: String, newLastMessage: Message?, currentUser: User) async throws {
        let batch = firestore.batch()
        let channelDocRef = getChannelDocRef(documentId: message.toId)
        let messageDocRef = getChannelMessageDocRef(channelId: message.toId, documentId: message.id)
        
        if lastMessageId == message.id {
            if newLastMessage == nil {
                let newLastMessage = Message(
                    id: UUID().uuidString,
                    fromId: currentUser.id,
                    toId: channelDocRef.documentID,
                    read: false,
                    isEdited: false,
                    text: "Deleted last messages",
                    timestamp: Timestamp(date: Date())
                )
                let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: newLastMessage, user: currentUser)))
                batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
            } else {
                let author = try await getUserDocRef(uuid: newLastMessage!.fromId).getDocument(as: User.self)
                let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: newLastMessage!, user: author)))
                batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
            }
        }
        
        batch.deleteDocument(messageDocRef)
        
        try await batch.commit()
    }
    
    static func deleteChannelMessages(messages: [Message], lastMessageId: String, newLastMessage: Message?, currentUser: User) async throws {
        guard messages.count > 0 else { return }
        
        let channelDocRef = getChannelDocRef(documentId: messages[0].toId)
        
        let batch = firestore.batch()
        
        if messages.contains(where: { $0.id == lastMessageId }) {
            if newLastMessage == nil {
                let newLastMessage = Message(
                    id: UUID().uuidString,
                    fromId: currentUser.id,
                    toId: channelDocRef.documentID,
                    read: false,
                    isEdited: false,
                    text: "Deleted last messages",
                    timestamp: Timestamp(date: Date())
                )
                let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: newLastMessage, user: currentUser)))
                batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
            } else {
                let author = try await getUserDocRef(uuid: newLastMessage!.fromId).getDocument(as: User.self)
                let lastMessageUpdateData = try encode(LastMessageUpdateData(lastMessage: UserMessage(message: newLastMessage!, user: author)))
                batch.updateData(lastMessageUpdateData, forDocument: channelDocRef)
            }
        }
        
        messages.forEach { message in
            batch.deleteDocument(getChannelMessageDocRef(channelId: message.toId, documentId: message.id))
        }
        
        try await batch.commit()
    }
}

extension FirebaseConstants {
    static func getUserDocRef(uuid: String) -> DocumentReference {
        usersCollection.document(uuid)
    }
    
    static func getProfileImageRef(uuid: String) -> StorageReference {
        storage.reference(withPath: "/profile_images/\(uuid)")
    }
    
    static func uploadImage(id: String, image: UIImage) async throws -> String {
        try await ImageUploader.uploadImage(id: id, image: image)
    }
}

extension FirebaseConstants {
    static func getChatMessagesCollection(ownerId: String, partnerId: String) -> CollectionReference {
        messagesCollection
            .document(ownerId)
            .collection(partnerId)
    }
    
    static func getRecentMessagesCollection(ownerId: String) -> CollectionReference {
        messagesCollection
            .document(ownerId)
            .collection("recent_messages")
    }
    
    static func getRecentMessageDocRef(ownerId: String, partnerId: String) -> DocumentReference {
        getRecentMessagesCollection(ownerId: ownerId)
            .document(partnerId)
    }
    
    static func getMessageDocRef(ownerId: String, toId: String, documentId: String? = nil) -> DocumentReference {
        let chatCollection = getChatMessagesCollection(ownerId: ownerId, partnerId: toId)
        
        if let documentId { return chatCollection.document(documentId) }
        return chatCollection.document()
    }
}

extension FirebaseConstants {
    static func getChannelDocRef(documentId: String? = nil) -> DocumentReference {
        if let documentId { return channelsCollection.document(documentId) }
        return channelsCollection.document()
    }
    
    static func getChannelMessagesCollection(channelId: String) -> CollectionReference {
        channelsCollection.document(channelId).collection("messages")
    }
    
    static func getChannelMessageDocRef(channelId: String, documentId: String? = nil) -> DocumentReference {
        let messages = getChannelMessagesCollection(channelId: channelId)
        if let documentId { return messages.document(documentId) }
        return messages.document()
    }
}
