//
//  Channels.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct ChannelsView: View {
    @State private var showingNewChannelView = false
    
    @EnvironmentObject var viewModel: ChannelsViewModel
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
//                ForEach(viewModel.)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            NewChatButton {
                showingNewChannelView = true
            }
            .padding()
        }
    }
}

#Preview {
    ChannelsView()
}
