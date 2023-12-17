//
//  User.swift
//  Chats
//
//  Created by Игорь Михайлов on 13.12.2023.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let username: String
    let fullName: String
    let profileImage: String
    let status: Statuses
}

struct EditableUser: Codable {
    var email: String = ""
    var username: String = ""
    var fullName: String = ""
    var status: Statuses = .available
}

struct UploadableUser: Codable {
    let fullName: String
    let profileImage: String
    let status: Statuses
}
