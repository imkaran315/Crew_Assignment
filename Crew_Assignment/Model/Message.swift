//
//  Message.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//

import Foundation


// MARK: - Message model
struct Message: Identifiable, Codable, Equatable {
    let id: String
    let message: String
    let type: MessageType
    var file: Attachment?
    let sender: SenderType
    let timestamp: Double
    
    // formatted date
    var date: Date {
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
}

enum MessageType: String, Codable {
    case text
    case file
}

enum SenderType: String, Codable {
    case user
    case agent
}

struct Attachment: Codable, Equatable {
    let path: String
    let fileSize: Int
    let thumbnail: Thumbnail?
}

struct Thumbnail: Codable, Equatable {
    let path: String
}
