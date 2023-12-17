//
//  LoginView.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authModel: AuthViewModel
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {        
            // MARK: Title
            VStack(alignment: .leading, spacing: 10) {
                HStack { Spacer() }
                
                Group {
                    Text("Hello")
                    Text("Welcome Back")
                        .foregroundStyle(.blue)
                }
                .font(.largeTitle.bold())
                
            }
            .padding(EdgeInsets(top: 60, leading: 20, bottom: 0, trailing: 0))
            
            Spacer()
            
            // MARK: Input
            VStack(spacing: 20) {
                
                Group {
                    TextField("Email", text: $authModel.editableUser.email)
                        .textFieldStyle(systemImage: "envelope")
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    SecureField("Password", text: $authModel.password)
                        .textFieldStyle(systemImage: "lock")
                        .focused($focusedField, equals: .password)
                        .submitLabel(.continue)
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        Text("Reset password...")
                    } label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .padding(.trailing, -20)
                
                Button {
                    authModel.login()
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .shadow(color: .gray, radius: 10)
                .padding(.top)
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
            
            
            
            Spacer()
            Spacer()
            
            // MARK: Button
            NavigationLink {
                RegistrationView()
            } label: {                
                AuthNavigationButtonLabel(text1: "Don't have an account?", text2: "Sign Up")
                    .padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    LoginView()
}
