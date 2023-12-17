//
//  SettingsView.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        ZStack {            
            VStack(spacing: 0) {
                SettingsHeader()
                    .padding(.bottom, 50)
                    .padding(.top, 30)
                                
                Group {
                    NavigationLink {
                        Text("Account")
                    } label: {
                        SettingsCell(text: "Account", color: .blue, systemImage: "key.fill")
                    }
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        SettingsCell(text: "Notifications", color: .red, systemImage: "bell.badge.fill")
                    }
                    NavigationLink {
                        Text("Starred Messages")
                    } label: {
                        SettingsCell(text: "Starred Messages", color: .yellow, systemImage: "star.fill")
                    }
                }
                .foregroundStyle(.primary)
                                
                Button {
                    authModel.logout()
                } label: {
                    Text("Log Out")
                        .foregroundStyle(.red)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(.systemGray6).opacity(0.5))
                }
                .padding(.top, 32)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView()
}
