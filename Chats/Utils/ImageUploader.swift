//
//  ImageUploader.swift
//  Chats
//
//  Created by Игорь Михайлов on 13.12.2023.
//

import SwiftUI

enum UploadError: Error, LocalizedError {
    case noJpegData
    
    var errorDescription: String? {
        switch self {
        case .noJpegData:
            return "Unable to get jpeg data from image"
        }
    }
}

struct ImageUploader {
    static func uploadImage(id: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { throw UploadError.noJpegData }
        
        let ref = FirebaseConstants.getProfileImageRef(uuid: id)
        
        let _ = try await ref.putDataAsync(imageData)
        
        return (try await ref.downloadURL()).absoluteString
    }
}
