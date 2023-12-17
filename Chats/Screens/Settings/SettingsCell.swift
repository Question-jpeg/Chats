//
//  SettingsCell.swift
//  Chats
//
//  Created by Игорь Михайлов on 11.12.2023.
//

import SwiftUI

struct SettingsCell: View {
    
    let text: String
    let color: Color
    let systemImage: String
    
    var body: some View {
        VStack {
            Divider()
                .opacity(0)
            HStack {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .padding(6)
                    .background(color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.trailing, 5)
                
                Text(text)
                    .font(.system(size: 15))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: 40)
            Divider()
        }
        .background(Color(.systemGray6).opacity(0.5))
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsCell(text: "Starred Messages", color: .yellow, systemImage: "star.fill")
        SettingsCell(text: "Security", color: .blue, systemImage: "key.fill")
        SettingsCell(text: "Notifications", color: .red, systemImage: "bell.badge.fill")
    }
}
