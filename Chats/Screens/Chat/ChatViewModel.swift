//
//  ChatViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import Firebase
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    struct ChatChanges: Equatable {
        let selectedMessages: [Message]
        let messageText: String
        let editingMessage: Message?
        let isSelectMode: Bool
    }
    
    var changes: ChatChanges {
        ChatChanges(selectedMessages: selectedMessages, messageText: messageText, editingMessage: editingMessage, isSelectMode: isSelectMode)
    }
    
    @Published var messages = [UserMessage]()
    @Published var selectedMessages = [Message]()
    @Published var messageText = ""
    @Published var scrollPosition: Int?
    @Published var editingMessage: Message?
    @Published var isSelectMode = false
    
    let chatIdentifier: ChatIdentifier
    let currentUser: User
    
    init(chatIdentifier: ChatIdentifier, currentUser: User) {
        self.chatIdentifier = chatIdentifier
        self.currentUser = currentUser
    }
    
    var isStart = true
    
    var listener: ListenerRegistration?
    
    func onAppear() {
        fetchMessages()
    }
    
    func onDisappear() {
        messages = []
        isStart = true
        listener?.remove()
        AppSingleton.shared.scrollPositions[chatIdentifier.id] = scrollPosition ?? messages.count
    }
    
    func isSelected(message: Message) -> Bool {
        selectedMessages.contains(where: { $0.id == message.id })
    }
    
    func turnOnSelection(message: Message) {
        if editingMessage != nil {
            editingMessage = nil
            messageText = ""
        }
        isSelectMode = true
        selectedMessages = [message]
    }
    
    func quitSelectionMode() {
        isSelectMode = false
        selectedMessages = []
    }
    
    func selectMessage(message: Message) {
        if let index = selectedMessages.firstIndex(where: { $0.id == message.id }) {
            selectedMessages.remove(at: index)
        } else {
            selectedMessages.append(message)
        }
    }
    
    func unfocus() {
        NotificationCenter.default.post(name: .didUnfocused, object: nil)
    }
    
    func scrollToBottom() {
        withAnimation {
            scrollPosition = messages.count
        }
    }
    
    func fetchMessages() {
        let query: Query
        if !chatIdentifier.isChannel {
            query = FirebaseConstants.getChatMessagesCollection(
                ownerId: FirebaseConstants.currentUserId!,
                partnerId: chatIdentifier.id
            )
            .order(by: "timestamp", descending: false)
        } else {
            query = FirebaseConstants.getChannelMessagesCollection(channelId: chatIdentifier.id)
                .order(by: "timestamp", descending: false)
        }
        
        listener = query.addSnapshotListener { [self] snapshot, _ in
            guard let changes = snapshot?.documentChanges else {
                messages = []
                return
            }
            Task {
                var cachedUsers: [User] = messages.map { $0.user }
                let listenerMessages: [ListenerUserMessage] = await changes.asyncCompactMap {
                    guard let message = try? $0.document.data(as: Message.self) else { return nil }
                    let user: User?
                    
                    if let cachedUser = cachedUsers.first(where: { $0.id == message.fromId }) {
                        user = cachedUser
                    } else {
                        user = try? await FirebaseConstants.getUserDocRef(uuid: message.fromId).getDocument(as: User.self)
                        if let user { cachedUsers.append(user) }
                    }
                    
                    guard let user else { return nil }
                    
                    return ListenerUserMessage(type: $0.type, message: UserMessage(message: message, user: user))
                }
                let addedMessages = listenerMessages.filter { $0.type == .added }.map { $0.message }
                let editedMessages = listenerMessages.filter { $0.type == .modified }.map { $0.message }
                let removedMessages = listenerMessages.filter { $0.type == .removed }.map { $0.message }
                
                var newMessages = messages
                
                newMessages.append(contentsOf: addedMessages)
                editedMessages.forEach { message in
                    if let index = newMessages.firstIndex(where: { $0.message.id == message.message.id }) {
                        newMessages[index] = message
                    }
                }
                removedMessages.forEach { message in
                    if let index = newMessages.firstIndex(where: { $0.message.id == message.message.id }) {
                        newMessages.remove(at: index)
                    }
                }
                
                
                if isStart {
                    messages = newMessages
                    isStart = false
                    scrollPosition = AppSingleton.shared.scrollPositions[chatIdentifier.id] ?? messages.count
                } else {
                    withAnimation {
                        messages = newMessages
                    }
                }
            }
        }
    }
    
    func sendMessage() {
        Task {
            do {
                let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                messageText = ""
                if !chatIdentifier.isChannel {
                    try await FirebaseConstants.sendMessage(text, toUserId: chatIdentifier.id)
                } else {
                    try await FirebaseConstants.sendChannelMessage(messageText: text, channelId: chatIdentifier.id, currentUser: currentUser)
                }
            } catch {
                print("DEBUG: Failed to send a message due to error: \(error.localizedDescription)")
            }
        }
    }
    
    func editMessage() {
        guard let editingMes = editingMessage else { return }
        Task {
            do {
                let text = messageText
                let recentMessageId = messages[messages.count-1].message.id
                messageText = ""
                editingMessage = nil
                if !chatIdentifier.isChannel {
                    try await FirebaseConstants.editMessage(text, message: editingMes, recentMessageId: recentMessageId)
                } else {
                    try await FirebaseConstants.editChannelMessage(text, message: editingMes, lastMessageId: recentMessageId, currentUser: currentUser)
                }
            } catch {
                print("DEBUG: Failed to edit a message due to error: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteMessage(message: Message) {
        if editingMessage?.id == message.id {
            messageText = ""
            editingMessage = nil
        }
        let recentMessageId = messages[messages.count-1].message.id
        let newRecentMessage = messages[safe: messages.count-2]?.message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            Task {
                do {
                    if !chatIdentifier.isChannel {
                        try await FirebaseConstants.deleteMessage(message: message, recentMessageId: recentMessageId, newRecentMessage: newRecentMessage)
                    } else {
                        try await FirebaseConstants.deleteChannelMessage(message: message, lastMessageId: recentMessageId, newLastMessage: newRecentMessage, currentUser: currentUser)
                    }
                } catch {
                    print("DEBUG: Failed to delete a message due to error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteSelected() {
        Task {
            do {
                isSelectMode = false
                
                let recentMessageId = messages[messages.count-1].message.id
                let leftMessages = messages.filter { message in
                    !selectedMessages.contains(where: { $0.id == message.message.id })
                }
                let newRecentMessage = leftMessages[safe: leftMessages.count-1]?.message
                
                if !chatIdentifier.isChannel {
                    try await FirebaseConstants.deleteMessages(messages: selectedMessages, recentMessageId: recentMessageId, newRecentMessage: newRecentMessage)
                } else {
                    try await FirebaseConstants.deleteChannelMessages(messages: selectedMessages, lastMessageId: recentMessageId, newLastMessage: newRecentMessage, currentUser: currentUser)
                }
                
                selectedMessages = []
            } catch {
                print("DEBUG: Failed to batch delete messages due to error: \(error.localizedDescription)")
            }
        }
    }
}
