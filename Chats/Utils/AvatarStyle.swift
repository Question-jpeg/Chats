//
//  AvatarStyle.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

extension Image {
    func avatarStyle(size: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
