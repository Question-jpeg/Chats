//
//  EditMessage.swift
//  Chats
//
//  Created by Игорь Михайлов on 16.12.2023.
//

import SwiftUI
import Firebase

struct EditMessageView: View {
    let message: Message
    let cancel: () -> Void
    
    var body: some View {
        
        HStack {
            Image(systemName: "pencil")
                .font(.title.bold())
                .foregroundStyle(.blue)
                .padding(.trailing, 10)
    
            Rectangle()
                .fill(.blue)
                .frame(width: 2)
            
            VStack(alignment: .leading) {
                Text("Edit Message")
                    .font(.system(size: 12))
                    .foregroundStyle(.blue)
                Text(message.text)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                cancel()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxHeight: 40)
    }
}

#Preview {
    EditMessageView(message: Message(id: "", fromId: "", toId: "", read: false, isEdited: false, text: "Test message text", timestamp: Timestamp(date: Date())), cancel: {})
}
