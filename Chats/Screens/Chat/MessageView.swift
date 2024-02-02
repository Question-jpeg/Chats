//
//  MessageView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import Firebase
import CachedAsyncImage

struct MessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatModel: ChatViewModel
    @State private var isTruncated: Bool? = nil
    
    let message: Message
    let author: User
    let position: Position
    
    @ViewBuilder var messageTextView: some View {
        Text(message.text)
            .font(.system(size: 16, design: .rounded))
            .foregroundStyle(message.isFromCurrentUser ? .white : (colorScheme == .dark ? .white : .black))
    }
    
    @ViewBuilder var messageView: some View {
        messageTextView
        
        Text("\(message.isEdited ? "edited" : "") \(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))")
            .font(.system(size: 10, design: .rounded))
            .foregroundStyle(((colorScheme == .dark || !message.isFromCurrentUser) ? .secondary : .white.opacity(0.8)) as Color)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            if !message.isFromCurrentUser && chatModel.chatIdentifier.isChannel {
                if position == .single || position == .last {
                    CachedAsyncImage(url: URL(string: author.profileImage)) { image in
                        image.avatarStyle(size: 30)
                    } placeholder: {
                        Image.getPlaceholderImage(size: 30)
                    }
                } else {
                    Color.clear.frame(width: 30, height: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if chatModel.chatIdentifier.isChannel && !message.isFromCurrentUser && (position == .single || position == .first)  {
                    Text(author.fullName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                HStack(alignment: .bottom, spacing: 5) {
                    if isTruncated == nil {
                        messageTextView
                            .opacity(0)
                            .background(GeometryReader { geo in
                                Color.clear.onAppear { isTruncated = geo.size.width > .screenWidth/2 }
                            })
                    } else if isTruncated! {
                        VStack(alignment: .trailing) {
                            messageView
                        }
                    } else {
                        messageView
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background {
                ChatBubble(isFromCurrentUser: message.isFromCurrentUser, position: position)
                    .fill(message.isFromCurrentUser ? .blue : Color(.systemGray5))
            }
            .contextMenu {
                if !chatModel.isSelectMode {
                    if message.isFromCurrentUser {
                        Button {
                            chatModel.editingMessage = message
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                    
                    Button {
                        chatModel.turnOnSelection(message: message)
                    } label: {
                        Label("Select", systemImage: "circle.badge.checkmark.fill")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        chatModel.deleteMessage(message: message)
                    } label: {
                        Label("Delete for all", systemImage: "trash")
                    }
                }
            }
            .padding(.leading, 10)
            .padding(message.isFromCurrentUser ? .leading : .trailing, 30)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}

//#Preview {
//    let curUser = User(id: "", email: "", username: "", fullName: "Full name", profileImage: "https://imgupscaler.com/images/samples/animal-before.webp", status: .available)
//    
//    let message = Message(
//        id: "",
//        fromId: "",
//        toId: "",
//        read: false,
//        isEdited: false,
//        text: "Test message",
//        timestamp: Timestamp(date: Date())
//    )
//    
//    return MessageView(message: message, position: .single)
//        .environmentObject(ChatViewModel(chatIdentifier: ChatIdentifier(id: "", isChannel: true), currentUser: curUser))
//}
