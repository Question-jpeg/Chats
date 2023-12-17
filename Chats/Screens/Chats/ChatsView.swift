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
    @EnvironmentObject var chatsModel: ChatsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(chatsModel.recentMessages) { recentMessage in
                    NavigationLink {
                        ChatView(user: recentMessage.user, chatsModel: chatsModel)
                    } label: {
                        VStack(spacing: 0) {
                            Divider()
                            ChatCell(user: recentMessage.user, message: recentMessage.message)
                                .padding(.vertical, 15)
                                .padding(.leading, 25)
                            Divider()
                        }
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
            ChatView(user: user, chatsModel: chatsModel)
        }   
    }
}

#Preview {
    ChatsView()
}
