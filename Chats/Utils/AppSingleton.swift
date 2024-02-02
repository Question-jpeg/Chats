//
//  AppSingleton.swift
//  Chats
//
//  Created by Игорь Михайлов on 31.12.2023.
//

import Foundation

class AppSingleton {
    static let shared = AppSingleton()
    
    var scrollPositions = [String: Int]()
}
