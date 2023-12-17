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
    @Published var messages = [Message]()
    @Published var selectedMessages = [Message]()
    @Published var messageText = ""
    @Published var scrollPosition: Int?
    @Published var editingMessage: Message?
    @Published var isSelectMode = false
    
    let user: User
    let chatsModel: ChatsViewModel
    
    var isStart = true
    
    var listener: ListenerRegistration?
    
    init(user: User, chatsModel: ChatsViewModel) {
        self.user = user
        self.chatsModel = chatsModel
        fetchMessages()
    }
    
    func onDisappear() {
        listener?.remove()
        chatsModel.scrollPositions[user.id] = scrollPosition ?? messages.count
    }
    
    func isSelected(message: Message) -> Bool {
        selectedMessages.contains(where: { $0.id == message.id })
    }
    
    func turnOnSelection(message: Message) {
        withAnimation {
            if editingMessage != nil {
                editingMessage = nil
                messageText = ""
            }
            isSelectMode = true
            selectedMessages = [message]
        }
    }
    
    func quitSelectionMode() {
        withAnimation {
            isSelectMode = false
            selectedMessages = []
        }
    }
    
    func selectMessage(message: Message) {
        withAnimation(.linear(duration: 0.1)) {
            if let index = selectedMessages.firstIndex(where: { $0.id == message.id }) {
                selectedMessages.remove(at: index)
            } else {
                selectedMessages.append(message)
            }
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
        let query = FirebaseConstants.getChatMessagesCollection(
            ownerId: FirebaseConstants.currentUserId!,
            partnerId: user.id
        )
            .order(by: "timestamp", descending: false)
        
        listener = query.addSnapshotListener { [self] snapshot, _ in
            guard let changes = snapshot?.documentChanges else { return }
            let listenerMessages: [ListenerMessage] = changes.compactMap {
                guard let message = try? $0.document.data(as: Message.self) else { return nil }
                return ListenerMessage(type: $0.type, message: message)
            }
            let addedMessages = listenerMessages.filter { $0.type == .added }.map { $0.message }
            let editedMessages = listenerMessages.filter { $0.type == .modified }.map { $0.message }
            let removedMessages = listenerMessages.filter { $0.type == .removed }.map { $0.message }
            
            var newMessages = messages
            
            newMessages.append(contentsOf: addedMessages)
            editedMessages.forEach { message in
                if let index = newMessages.firstIndex(where: { $0.id == message.id }) {
                    newMessages[index] = message
                }
            }
            removedMessages.forEach { message in
                if let index = newMessages.firstIndex(where: { $0.id == message.id }) {
                    newMessages.remove(at: index)
                }
            }
            
            
            if isStart {
                messages = newMessages
                isStart = false
                scrollPosition = chatsModel.scrollPositions[user.id] ?? messages.count
            } else {
                withAnimation {
                    messages = newMessages
                }
            }
        }
    }
    
    func sendMessage() {
        Task {
            do {
                let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                messageText = ""
                try await FirebaseConstants.sendMessage(text, toUserId: user.id)
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
                let recentMessageId = messages[messages.count-1].id
                messageText = ""
                editingMessage = nil
                try await FirebaseConstants.editMessage(text, message: editingMes, recentMessageId: recentMessageId)
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
        let recentMessageId = messages[messages.count-1].id
        let newRecentMessage = messages[safe: messages.count-2]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task {
                do {
                    try await FirebaseConstants.deleteMessage(message: message, recentMessageId: recentMessageId, newRecentMessage: newRecentMessage)
                } catch {
                    print("DEBUG: Failed to delete a message due to error: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func deleteSelected() {
        Task {
            do {
                withAnimation {
                    isSelectMode = false
                }
                
                let recentMessageId = messages[messages.count-1].id
                let leftMessages = messages.filter { message in
                    !selectedMessages.contains(where: { $0.id == message.id })
                }
                let newRecentMessage = leftMessages[safe: leftMessages.count-1]
                
                try await FirebaseConstants.deleteMessages(messages: selectedMessages, recentMessageId: recentMessageId, newRecentMessage: newRecentMessage)
                
                selectedMessages = []
            } catch {
                print("DEBUG: Failed to batch delete messages due to error: \(error.localizedDescription)")
            }
        }
    }
}
