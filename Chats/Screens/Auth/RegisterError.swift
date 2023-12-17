//
//  RegisterError.swift
//  Chats
//
//  Created by Игорь Михайлов on 14.12.2023.
//

import Foundation

enum RegisterError: Error, LocalizedError {
    case emptyUsername, emptyFullName, emptyProfileImage
    
    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Username must not be empty"
        case .emptyFullName:
            return "FullName must not be empty"
        case .emptyProfileImage:
            return "Profile image must be set"
        }
    }
}
