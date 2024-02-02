//
//  CreateChannelView.swift
//  Chats
//
//  Created by Игорь Михайлов on 27.12.2023.
//

import SwiftUI

struct CreateChannelView: View {
    @State private var showingImagePicker = false
    @ObservedObject var viewModel: CreateChannelViewModel
    let onCompletion: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 32) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button {
                        showingImagePicker = true
                    } label: {
                        if let image = viewModel.channelImage {
                            Image(uiImage: image)
                                .avatarStyle(size: 64)
                        } else {
                            Image(systemName: "plus.circle")
                                .avatarStyle(size: 64)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    TextField("Enter a name for your channel", text: $viewModel.channelName)
                        .font(.system(size: 15))
                    
                    Divider()
                    
                    Text("Please provide a channel name and icon")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
                
            }
            .padding()
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.createChannel(onCompletion: onCompletion)
                } label: {
                    Text("Create").bold()
                }
                .disabled(viewModel.channelName.isEmpty || viewModel.isLoading)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $viewModel.channelImage, onSet: {})
        }
    }
}

#Preview {
    CreateChannelView(viewModel: CreateChannelViewModel(authModel: AuthViewModel()), onCompletion: {})
}
