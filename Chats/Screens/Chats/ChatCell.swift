//
//  UserCell.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import CachedAsyncImage

struct ChatCell: View {
    let user: User
    let message: Message
    
    var messageDateString: String {
        let date = message.timestamp.dateValue()
        
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        
        return ""
    }
    
    var body: some View {
        HStack(spacing: 10) {
            CachedAsyncImage(url: URL(string: user.profileImage)!) { image in
                image.avatarStyle(size: 48)
            } placeholder: {
                Image.getPlaceholderImage(size: 48)
            }
            
            VStack(alignment: .leading) {
                Text(user.fullName)
                    .fontWeight(.semibold)
                
                HStack(spacing: 0) {
                    Group {
                        Text(message.fromId == FirebaseConstants.currentUserId ? "You: " : "")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                        +
                        Text(message.text)
                    }
                    .lineLimit(1)
                    
                    Spacer()
                    
                    Text(messageDateString)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
            }
            .font(.system(size: 14))
            
            Spacer()
        }
    }
    
}

#Preview {
    UserCell(user: User(id: "1", email: "test@gmail.com", username: "test", fullName: "Full Test", profileImage: "chickanka", status: .available))
}
