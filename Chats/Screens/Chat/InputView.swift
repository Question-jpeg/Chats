//
//  InputView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import Firebase

struct InputView: View {
    @EnvironmentObject var chatModel: ChatViewModel
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(.separator)
                .frame(height: 2)
            
            if let message = chatModel.editingMessage {
                EditMessageView(message: message, cancel: {
                    withAnimation {
                        chatModel.editingMessage = nil
                        chatModel.messageText = ""
                    }
                })
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .padding(.trailing, 10)
            }
            
            HStack {
                TextField("Message..", text: $chatModel.messageText, axis: .vertical)
                    .focused($isFocused)
                    .lineLimit(5)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button {
                    if chatModel.editingMessage != nil {
                        chatModel.editMessage()
                    } else {
                        chatModel.sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.title3)
                        .padding(10)
                        .background(chatModel.messageText.isEmpty ? Color(.systemGray5) : .blue)
                        .clipShape(Circle())
                }
                .disabled(chatModel.messageText.isEmpty)
                .tint(.white)
            }
            .padding(.horizontal)
            
            Rectangle()
                .fill(.clear)
                .frame(height: 2)
        }
        .onChange(of: chatModel.editingMessage) { oldValue, newValue in
            if chatModel.editingMessage != nil {
                isFocused = true
                chatModel.messageText = chatModel.editingMessage!.text
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didUnfocused), perform: { _ in
            isFocused = false
        })
        .offset(y: chatModel.isSelectMode ? 100 : 0)
    }
}

//#Preview {
//    InputView(editMessage: .constant(Message(id: "", fromId: "", toId: "", read: false, isEdited: false, text: "Test edit message", timestamp: Timestamp(date: Date()))), messageText: .constant("Test text"), disabled: true, action: {})
//}
