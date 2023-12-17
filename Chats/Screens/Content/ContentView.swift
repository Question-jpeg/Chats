//
//  ContentView.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        Group {
            if authModel.userSession != nil {
                MainTabBar()
            } else if authModel.isUserSessionLoading {
                ProgressView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
