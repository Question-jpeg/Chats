//
//  NewMessageView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = NewMessageViewModel()
    
    @Binding var selectedChatUser: User?
        
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchText: $viewModel.searchText)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.filteredUsers) { user in
                        Button {
                            selectedChatUser = user
                            dismiss()
                        } label: {
                            UserCell(user: user)
                        }
                        .tint(.primary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
            }
        }
        .animation(.default, value: viewModel.searchText)
    }
}

#Preview {
    NewMessageView(selectedChatUser: .constant(User(id: "", email: "", username: "test", fullName: "Test Name", profileImage: "", status: .available)))
}
