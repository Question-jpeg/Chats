//
//  ChannelsViewModel.swift
//  Chats
//
//  Created by Игорь Михайлов on 17.12.2023.
//

import Firebase

@MainActor
class ChannelsViewModel: ObservableObject {
    
    @Published var channels = [Channel]()
    
    var listener: ListenerRegistration?
    
    func onAppear() {
        fetchChannels()
    }
    
    func onDisappear() {
        listener?.remove()
    }
    
    func fetchChannels() {
        guard let currentUserId = FirebaseConstants.currentUserId else { return }
        
        let query = FirebaseConstants
            .channelsCollection
            .whereField("uids", arrayContains: currentUserId)
            .order(by: "lastMessage.message.timestamp", descending: true)
        
        listener = query.addSnapshotListener { [self] snapshot, _ in
            guard let changes = snapshot?.documentChanges else {
                channels = []
                return
            }
            Task {
                let listenerChannels: [ListenerChannel] = await changes
                    .asyncCompactMap {
                        guard let channel = try? $0.document.data(as: Channel.self) else { return nil }
                    
                        return ListenerChannel(type: $0.type, channel: channel)
                    }
                
                let newChannels = listenerChannels.filter { $0.type == .added }.map { $0.channel }
                let modifiedChannels = listenerChannels.filter { $0.type == .modified }.map { $0.channel }
                let deletedChannels = listenerChannels.filter { $0.type == .removed }.map { $0.channel }
                
                var updated = channels
                
                updated.append(contentsOf: newChannels)
                modifiedChannels.forEach { channel in
                    if let index = updated.firstIndex(where: { $0.id == channel.id }) {
                        updated[index] = channel
                    }
                }
                deletedChannels.forEach { channel in
                    if let index = updated.firstIndex(where: { $0.id == channel.id }) {
                        updated.remove(at: index)
                    }
                }
                
                channels = updated
            }
        }
    }
}
