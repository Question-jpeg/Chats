//
//  CreateGroupView.swift
//  Chats
//
//  Created by Игорь Михайлов on 18.12.2023.
//

import SwiftUI

struct SelectGroupMembersView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: CreateChannelViewModel
    
    init(authModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: CreateChannelViewModel(authModel: authModel))
    }
    
    var nextButton: some View {
        NavigationLink {
            CreateChannelView(viewModel: viewModel, onCompletion: { dismiss() })
        } label: {
            Text("Next")
        }
    }
    
    var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(searchText: $viewModel.searchText)
                    .padding()
                
                VStack {
                    Divider()
                    SelectedGroupMembersView(users: viewModel.selectedUsers, deselect: viewModel.deselectUser)
                    Divider()
                }
                
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.filteredUsers) { user in
                            Button {
                                viewModel.selectUser(user: user)
                            } label: {
                                HStack {
                                    UserCell(user: user)
                                    Image(systemName: viewModel.isSelected(user: user) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .tint(.primary)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 25)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    nextButton
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
        }
        .animation(.default, value: viewModel.selectedUsers)
        .animation(.default, value: viewModel.searchText)
    }
}

#Preview {
    SelectGroupMembersView(authModel: AuthViewModel())
}
