//
//  MainTabBar.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

enum TabBarItems: String {
    case Chats, Channels, Settings
}

struct MainTabBar: View {
    
    @State private var selection = TabBarItems.Chats
    @StateObject var chatsModel = ChatsViewModel()
    @StateObject var channelsModel = ChannelsViewModel()
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ChatsView(chatsModel: chatsModel)
                    .tabItem {
                        Image(systemName: "bubble.left")
                            .environment(\.symbolVariants, selection == .Chats ? .fill : .none)
                    }
                    .tag(TabBarItems.Chats)
                    
                
                ChannelsView(channelsModel: channelsModel)
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .environment(\.symbolVariants, selection == .Channels ? .fill : .none)
                    }
                    .tag(TabBarItems.Channels)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear.circle")
                            .environment(\.symbolVariants, selection == .Settings ? .fill : .none)
                    }
                    .tag(TabBarItems.Settings)
            }
            .navigationTitle(selection.rawValue)
        }
        .onAppear {
            chatsModel.onAppear()
            channelsModel.onAppear()
        }
        .onDisappear {
            chatsModel.onDisappear()
            channelsModel.onDisappear()
        }
    }
}

#Preview {
    MainTabBar()
}
