//
//  UserCell.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import CachedAsyncImage

struct UserCell: View {
    
    let user: User
    
    var body: some View {
        HStack(spacing: 10) {
            CachedAsyncImage(url: URL(string: user.profileImage)!) { image in
                image.avatarStyle(size: 48)
            } placeholder: {
                Image.getPlaceholderImage(size: 48)
            }
        
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(user.fullName)
                    .font(.system(size: 14))
            }
            
            Spacer()
        }
    }
}

#Preview {
    UserCell(user: User(id: "1", email: "test@gmail.com", username: "test", fullName: "Full Test", profileImage: "chickanka", status: .available))
}
