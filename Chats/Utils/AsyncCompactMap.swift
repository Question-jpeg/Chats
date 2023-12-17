//
//  AsyncCompactMap.swift
//  Chats
//
//  Created by Игорь Михайлов on 15.12.2023.
//

import Foundation

extension Sequence {
    func asyncCompactMap<T>(
            _ transform: (Element) async throws -> T?
        ) async -> [T] {
            var values = [T]()

            for element in self {
                guard let transformed = try? await transform(element) else { continue }
                values.append(transformed)
            }

            return values
        }
    
    func asyncForEach(_ body: (Element) async throws -> Void) async {
        for element in self {
            try? await body(element)
        }
    }
}
