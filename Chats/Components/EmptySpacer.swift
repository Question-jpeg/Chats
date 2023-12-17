//
//  EmpySpacer.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

struct EmptySpacer: View {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: width ?? nil, height: height ?? nil)
    }
}

#Preview {
    EmptySpacer()
}
