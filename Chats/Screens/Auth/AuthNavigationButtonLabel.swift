//
//  AuthNavigationButton.swift
//  Chats
//
//  Created by Игорь Михайлов on 14.12.2023.
//

import SwiftUI

struct AuthNavigationButtonLabel: View {
    
    let text1: String
    let text2: String
    
    var body: some View {
            HStack {
                Text(text1)
                    .font(.system(size: 14))
                Text(text2)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.vertical, 10)
    }
}

#Preview {
    AuthNavigationButtonLabel(text1: "Already have an account?", text2: "Sign In")
}
