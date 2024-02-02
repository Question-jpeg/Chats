//
//  Channels.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct ChannelsView: View {
    @State private var showingNewChannelView = false
    
    @EnvironmentObject var authModel: AuthViewModel
    @ObservedObject var channelsModel: ChannelsViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(channelsModel.channels) { channel in
                    NavigationLink {
                        ChatView(chatInfo: ChatInfo(
                            id: channel.id,
                            name: channel.name,
                            image: channel.image,
                            isChannel: true), currentUser: authModel.userSession!)
                    } label: {
                        ChannelCell(channel: channel)
                    }
                    .tint(.primary)
                }
                EmptySpacer(height: 80)
            }
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottomTrailing) {
            NewChatButton {
                showingNewChannelView = true
            }
            .padding()
        }
        .sheet(isPresented: $showingNewChannelView) {
            SelectGroupMembersView(authModel: authModel)
        }
        .animation(.default, value: channelsModel.channels)
    }
}

#Preview {
    ChannelsView(channelsModel: ChannelsViewModel())
}
