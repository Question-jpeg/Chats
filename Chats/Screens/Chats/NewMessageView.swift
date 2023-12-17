//
//  NewMessageView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var newMessageModel = NewMessageViewModel()
    
    @Binding var selectedChatUser: User?
    @State private var searchText = ""
        
    var filteredUsers: [User] {
        let users = newMessageModel.users.filter { user in
            user.id != FirebaseConstants.currentUserId
        }
        if searchText.isEmpty { return users }
        return users.filter { user in
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchText: $searchText)
                .padding()
                .padding(.horizontal, 5)
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(filteredUsers) { user in
                        Button {
                            selectedChatUser = user
                            dismiss()
                        } label: {
                            UserCell(user: user)
                                .padding(.horizontal, 25)
                        }
                        .tint(.primary)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    NewMessageView(selectedChatUser: .constant(User(id: "", email: "", username: "test", fullName: "Test Name", profileImage: "", status: .available)))
}
