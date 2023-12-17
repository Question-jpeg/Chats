//
//  LoginView.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authModel: AuthViewModel
    @State private var showingImagePicker = false
    @FocusState var focusedField: Field?
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    // MARK: Title
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Spacer() }
                        
                        Group {
                            Text("Get Started")
                            Text("Create your account")
                                .foregroundStyle(.blue)
                        }
                        .font(.largeTitle.bold())
                        
                    }
                    .padding(EdgeInsets(top: 60, leading: 20, bottom: 30, trailing: 0))
                    
                    // MARK: Image
                    VStack(spacing: 10) {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Image.getAvatarImage(fromUIImage: authModel.image, size: 100)
                        }
                        Text("Profile Photo")
                            .foregroundStyle(Color(.systemGray2))
                    }
                    
                    // MARK: Input
                    VStack(spacing: 20) {
                        
                        Group {
                            TextField("Email", text: $authModel.editableUser.email)
                                .textFieldStyle(systemImage: "envelope")
                                .focused($focusedField, equals: .email)
                                .onSubmit { focusedField = .username }
                            
                            TextField("Username", text: $authModel.editableUser.username)
                                .textFieldStyle(systemImage: "person")
                                .focused($focusedField, equals: .username)
                                .onSubmit { focusedField = .fullName }
                            
                            TextField("Full Name", text: $authModel.editableUser.fullName)
                                .textFieldStyle(systemImage: "person")
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(false)
                                .focused($focusedField, equals: .fullName)
                                .onSubmit { focusedField = .password }
                            
                            SecureField("Password", text: $authModel.password)
                                .textFieldStyle(systemImage: "lock")
                                .submitLabel(.continue)
                                .focused($focusedField, equals: .password)
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        
                        Button {
                            authModel.register()
                        } label: {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                        .shadow(color: .gray, radius: 10)
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 20)
                }
            }
            
            Button {
                dismiss()
            } label: {
                AuthNavigationButtonLabel(text1: "Already have an account?", text2: "Sign In")
                    .padding(.bottom, 5)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $authModel.image) {}
        }
        .toolbar(.hidden)
    }
}

#Preview {
    RegistrationView()
}
