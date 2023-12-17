//
//  TextFieldStyleModifier.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI


struct TextFieldStyleModifier: ViewModifier {
    
    let systemImage: String
    
    func body(content: Content) -> some View {
        VStack {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 30)
                    .foregroundStyle(.gray)
                content
            }
            
            Rectangle()
                .fill(Color(.systemGray2))
                .frame(height: 1)
                .padding(.top, 5)
        }
    }
}

extension View {
    func textFieldStyle(systemImage: String) -> some View {
        self
            .modifier(TextFieldStyleModifier(systemImage: systemImage))
    }
}
