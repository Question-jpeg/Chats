//
//  ChannelsViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 17.12.2023.
//

import Foundation

class ChannelsViewModel: ObservableObject {
    
    @Published var recentMessages = [RecentMessage]()
    
    func onDisappear() {
        
    }
}
