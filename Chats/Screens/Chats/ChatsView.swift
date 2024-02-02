//
//  ChatsView.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct ChatsView: View {
    @State private var showingNewMessageView = false
    @State private var selectedChatUser: User?
    @ObservedObject var chatsModel: ChatsViewModel
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(chatsModel.recentMessages) { recentMessage in
                    NavigationLink {
                        ChatView(chatInfo: ChatInfo(
                            id: recentMessage.user.id,
                            name: recentMessage.user.username,
                            image: recentMessage.user.profileImage,
                            isChannel: false), currentUser: authModel.userSession!)
                    } label: {
                        ChatCell(user: recentMessage.user, message: recentMessage.message)
                    }
                    .tint(.primary)
                }
                EmptySpacer(height: 80)
            }
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottomTrailing) {
            NewChatButton {
                showingNewMessageView = true
            }
            .padding()
        }
        .sheet(isPresented: $showingNewMessageView) {
            NewMessageView(selectedChatUser: $selectedChatUser)
        }
        .navigationDestination(item: $selectedChatUser) { user in
            ChatView(chatInfo: ChatInfo(
                id: user.id,
                name: user.username,
                image: user.profileImage,
                isChannel: false), currentUser: authModel.userSession!
            )
        }
        .animation(.default, value: chatsModel.recentMessages)
    }
}

#Preview {
    ChatsView(chatsModel: ChatsViewModel())
}
