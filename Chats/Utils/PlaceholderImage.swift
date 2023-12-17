//
//  PlaceholderImage.swift
//  Chats
//
//  Created by Игорь Михайлов on 13.12.2023.
//

import SwiftUI

extension Image {
    @ViewBuilder
    static func getAvatarImage(fromUIImage image: UIImage?, size: CGFloat) -> some View {
        if image == nil {
            getPlaceholderImage(size: size)
        } else {
            Image(uiImage: image!)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
    
    static func getPlaceholderImage(size: CGFloat) -> some View {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(size/4)
                .background(Color(.systemGray5))
                .foregroundStyle(.gray)
                .frame(width: size, height: size)
                .clipShape(Circle())
    }
}
