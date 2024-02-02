//
//  SelectedGroupMembersView.swift
//  Chats
//
//  Created by Игорь Михайлов on 18.12.2023.
//

import SwiftUI
import CachedAsyncImage

struct SelectedGroupMembersView: View {
    let users: [User]
    let deselect: (User) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(users) { user in
                    Button {
                        deselect(user)
                    } label: {
                        VStack {
                            CachedAsyncImage(url: URL(string: user.profileImage)!) { image in
                                image
                                    .avatarStyle(size: 60)
                            } placeholder: {
                                Image.getPlaceholderImage(size: 60)
                            }
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 8)
                                    .padding(5)
                                    .background(.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.white))
                                    .shadow(radius: 10)
                                
                            }
                            
                            Text(user.fullName)
                                .font(.system(size: 11, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                        }
                    }
                    .tint(.primary)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SelectedGroupMembersView(users: [], deselect: {_ in})
}
