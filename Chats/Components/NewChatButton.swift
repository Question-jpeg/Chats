//
//  NewChatButton.swift
//  Chats
//
//  Created by Игорь Михайлов on 17.12.2023.
//

import SwiftUI

struct NewChatButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.pencil")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .offset(x: 2, y: -1)
                .padding()
                .foregroundStyle(.white)
                .background(Color(.systemBlue))
                .clipShape(Circle())
        }
    }
}

#Preview {
    NewChatButton(action: {})
}
