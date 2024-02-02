//
//  ChatView.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI
import CachedAsyncImage

struct ChatView: View {
    let chatInfo: ChatInfo
    
    @StateObject var viewModel: ChatViewModel
    
    init(chatInfo: ChatInfo, currentUser: User) {
        self.chatInfo = chatInfo
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            chatIdentifier: ChatIdentifier(id: chatInfo.id, isChannel: chatInfo.isChannel), currentUser: currentUser)
        )
    }
    
    func sendMessage() {
        viewModel.sendMessage()
    }
    
    func editMessage() {
        viewModel.editMessage()
    }
    
    func getPosition(for index: Int) -> Position {
        let messages = viewModel.messages
        let prev = messages[safe: index-1]?.message
        let cur = messages[index].message
        let next = messages[safe: index+1]?.message
        
        guard let prev else {
            guard let next else { return .single }
            return next.isFromCurrentUser == cur.isFromCurrentUser ? .first : .single
        }
        guard let next else {
            return prev.isFromCurrentUser == cur.isFromCurrentUser ? .last : .single
        }
        
        if prev.isFromCurrentUser != cur.isFromCurrentUser {
            return next.isFromCurrentUser != cur.isFromCurrentUser ? .single : .first
        }
        
        if prev.isFromCurrentUser == cur.isFromCurrentUser {
            return next.isFromCurrentUser == cur.isFromCurrentUser ? .middle : .last
        }
        
        return .single
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 2) {
                    EmptySpacer(height: 50)
                    
                    ForEach(0..<viewModel.messages.count+1, id: \.self) { index in
                        if index == viewModel.messages.count {
                            EmptySpacer(height: 10)
                        } else {
                            let message = viewModel.messages[index].message
                            let author = viewModel.messages[index].user
                            let position = getPosition(for: index)
                            HStack {
                                if viewModel.isSelectMode {
                                    Image(systemName: viewModel.isSelected(message: message) ? "checkmark.circle.fill" : "circle" )
                                        .padding(.leading, 20)
                                        .foregroundStyle(.blue)
                                        .font(.title2)
                                }
                                MessageView(message: message, author: author, position: position)
                                    .background(message.id == viewModel.editingMessage?.id ? .blue.opacity(0.2) : .clear)
                                    .padding(.top, (position == .first || position == .single) ? 5 : 0)
                                    .padding(.bottom, (position == .last || position == .single) ? 5 : 0)
                            }
                            .contentShape(Rectangle())
                            .overlay(viewModel.isSelected(message: message) ? .blue.opacity(0.2) : .clear)
                            .onTapGesture {
                                if viewModel.isSelectMode {
                                    viewModel.selectMessage(message: message)
                                }
                                
                                viewModel.unfocus()
                            }
                        }
                    }
                    
                    EmptySpacer(height: 10)
                }
                .scrollTargetLayout()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onReceive(NotificationCenter.default.publisher(for: .didUpdatedTheScrollHeight)) { data in
                                if let endY = data.object as? CGFloat {
                                    let bottomOffset = geo.frame(in: .global).maxY - endY
                                    if bottomOffset <= 200 {
                                        viewModel.scrollToBottom()
                                    }
                                }
                            }
                    }
                )
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $viewModel.scrollPosition, anchor: .bottom)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: viewModel.messages.count) { oldValue, _ in
                            if oldValue != 0 {
                                let endY = geo.frame(in: .global).maxY
                                NotificationCenter.default.post(name: .didUpdatedTheScrollHeight, object: endY)
                            }
                        }
                }
            )
            InputView()
        }
        .toolbar() {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 10) {
                    if chatInfo.image != nil {
                        CachedAsyncImage(url: URL(string: chatInfo.image!)) { image in
                            image.avatarStyle(size: 40)
                        } placeholder: {
                            if chatInfo.isChannel {
                                Image.getChannelPlaceholderImage(size: 40)
                            } else {
                                Image.getPlaceholderImage(size: 40)
                            }
                        }
                    } else {
                        Image.getChannelPlaceholderImage(size: 40)
                    }
                    
                    Text(chatInfo.name)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.leading, 20)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    Text("Test")
                } label: {
                    Text("Go")
                }
            }
            
            if viewModel.isSelectMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.deleteSelected()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.quitSelectionMode()
                    }
                }
            }
        }
        .animation(.default, value: viewModel.changes)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .environmentObject(viewModel)
    }
}

//#Preview {
//    ChatView(user: User(id: "", email: "", username: "test", fullName: "Test Name", profileImage: "", status: .available))
//}
