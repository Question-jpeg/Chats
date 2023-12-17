//
//  MessageView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

struct MessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatModel: ChatViewModel
    @State private var isTruncated: Bool? = nil
    
    let message: Message
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
        HStack {
            if message.isFromCurrentUser {
                Spacer()
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
                            withAnimation {
                                chatModel.editingMessage = message
                            }                            
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
            .padding(.horizontal)
            .padding(message.isFromCurrentUser ? .leading : .trailing, 30)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
        
    }
}

#Preview {
    VStack(spacing: 0) {
        //        ForEach(ChatViewModel.mockMessages) { message in
        //            MessageView(message: message, position: .first)
        //        }
    }
}
