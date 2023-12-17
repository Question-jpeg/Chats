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
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ChatsView()
                    .tabItem {
                        Image(systemName: "bubble.left")
                            .environment(\.symbolVariants, selection == .Chats ? .fill : .none)
                    }
                    .tag(TabBarItems.Chats)
                    
                
                ChannelsView()
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
        .onDisappear {
            chatsModel.onDisappear()
        }
        .environmentObject(chatsModel)
    }
}

#Preview {
    MainTabBar()
}
