//
//  ChatBubble.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

enum Position {
    case first, middle, last, single
}

struct ChatBubble: Shape {
    let isFromCurrentUser: Bool
    let position: Position
    
    func path(in rect: CGRect) -> Path {
        var corners: UIRectCorner = [
            isFromCurrentUser ? .topLeft : .topRight,
            isFromCurrentUser ? .bottomLeft : .bottomRight,
            
        ]
        
        if position == .single || position == .first {
            corners.insert(isFromCurrentUser ? .topRight : .topLeft)
        }
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: .init(width: 12, height: 12)
        )
        
        if position == .last || position == .single {
            if isFromCurrentUser {
                path.move(to: .init(x: rect.maxX, y: rect.maxY-10))
                path.addQuadCurve(to: .init(x: rect.maxX+10, y: rect.maxY+5), controlPoint: .init(x: rect.maxX, y: rect.maxY))
                path.addQuadCurve(to: .init(x: rect.maxX-10, y: rect.maxY), controlPoint: .init(x: rect.maxX-5, y: rect.maxY+5))
                path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            } else {
                path.move(to: .init(x: 0, y: rect.maxY-10))
                path.addQuadCurve(to: .init(x: -10, y: rect.maxY+5), controlPoint: .init(x: 0, y: rect.maxY))
                path.addQuadCurve(to: .init(x: 10, y: rect.maxY), controlPoint: .init(x: 5, y: rect.maxY+5))
                path.addLine(to: .init(x: 0, y: rect.maxY))
            }
        }
        
        return Path(path.cgPath)
    }
}

#Preview {
    ChatBubble(isFromCurrentUser: true, position: .middle)
        .frame(width: 80, height: 30)
}
