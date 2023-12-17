//
//  SettingsHeader.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

extension View {
    func cancelUpdateButtonStyle(color: Color) -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(Capsule())
    }
}

struct SettingsHeader: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    @State private var showImagePicker = false
    
    var body: some View {
        HStack {
            Button {
                showImagePicker.toggle()
            } label: {
                Image.getAvatarImage(fromUIImage: authModel.image, size: 64)
                    .padding(.leading)
                    .padding(.trailing, 5)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $authModel.image) {
                    authModel.hasImageChanged = true
                }
            }
            .tint(.primary)
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("Enter your name", text: $authModel.editableUser.fullName)
                    .font(.system(size: 18))
                
                Menu {
                    Picker("Status", selection: $authModel.editableUser.status) {
                        ForEach(Statuses.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                } label: {
                    Text(authModel.editableUser.status.rawValue)
                        .font(.system(size: 14))
                }
                .tint(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6).opacity(0.5))
        .overlay(alignment: .bottomTrailing) {
            if authModel.hasChanges {
                HStack {
                    if !authModel.isUpdateLoading {
                        Button {
                            authModel.cancelUpdate()
                        } label: {
                            Label {
                                Text("Cancel")
                            } icon: {
                                Image(systemName: "xmark")
                            }
                            .cancelUpdateButtonStyle(color: .pink)
                        }
                    }
                    Button {
                        authModel.update()
                    } label: {
                        Label {
                            Text(authModel.isUpdateLoading ? "Saving" : "Save")
                        } icon: {
                            if !authModel.isUpdateLoading {
                                Image(systemName: "checkmark")
                            }
                        }
                        .cancelUpdateButtonStyle(color: authModel.isUpdateLoading ? .secondary : .blue)
                    }
                }
                .offset(x: -10, y: 20)
            }
        }
    }
}

#Preview {
    SettingsHeader()
}
