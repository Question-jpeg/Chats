//
//  UserCell.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import CachedAsyncImage

struct ChannelCell: View {
    let channel: Channel
    
    var messageDateString: String {
        let date = channel.lastMessage.message.timestamp.dateValue()
        
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        
        return ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                if channel.image != nil {
                    CachedAsyncImage(url: URL(string: channel.image!)) { image in
                        image.avatarStyle(size: 48)
                    } placeholder: {
                        Image.getChannelPlaceholderImage(size: 48)
                    }
                } else {
                    Image.getChannelPlaceholderImage(size: 48)
                }
                
                VStack(alignment: .leading) {
                    Text(channel.name)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 0) {
                        Group {
                            Text(channel.lastMessage.user.fullName + ": ")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 12))
                            +
                            Text(channel.lastMessage.message.text)
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
            .padding(.vertical, 15)
            .padding(.leading, 25)
            Divider()
        }
    }
}

//#Preview {
//    ChannelCell(channel: Channel(id: "a", name: "Test channel", uids: [], lastMessage: "Кто то покакал", image: nil))
//}
