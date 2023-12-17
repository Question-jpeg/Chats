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
