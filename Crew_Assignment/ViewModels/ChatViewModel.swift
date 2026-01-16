//
//  ChatViewModel.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//


import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    // Persistence file URL
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedMessages.json")
    
    init() {
        loadMessages()
    }
    
    // MARK: - Core Logic
    
    func sendMessage(text: String) {
        let newMessage = Message(
            id: UUID().uuidString,
            message: text,
            type: .text,
            file: nil,
            sender: .user,
            timestamp: Date().timeIntervalSince1970 * 1000
        )
        addMessage(newMessage)
    }
    
    func sendImage(image: UIImage) {
        // 1. Save Image to Disk
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            
            // 2. Create Message Object
            let attachment = Attachment(
                path: url.absoluteString, // Local path
                fileSize: data.count,
                thumbnail: nil
            )
            
            let newMessage = Message(
                id: UUID().uuidString,
                message: "", // Caption can be empty
                type: .file,
                file: attachment,
                sender: .user,
                timestamp: Date().timeIntervalSince1970 * 1000
            )
            addMessage(newMessage)
            
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    private func addMessage(_ msg: Message) {
        DispatchQueue.main.async {
            self.messages.append(msg)
            self.saveMessages()
        }
    }
    
    // MARK: - Persistence & Seeding
    
    private func saveMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    private func loadMessages() {
        do {
            // Check if local file exists
            if FileManager.default.fileExists(atPath: savePath.path) {
                let data = try Data(contentsOf: savePath)
                messages = try JSONDecoder().decode([Message].self, from: data)
            } else {
                // First Launch: Load Seed Data
                loadSeedData()
            }
        } catch {
            print("Error loading data: \(error)")
            // Fallback to seed if load fails
            loadSeedData()
        }
    }
    
    private func loadSeedData() {
        // Mock data from PDF
        let jsonString = """
        [
            { "id": "msg-001", "message": "Hi! I need help booking a flight to Mumbai.", "type": "text", "sender": "user", "timestamp": 1703520000000 },
            { "id": "msg-002", "message": "Hello! I'd be happy to help you. When are you planning to travel?", "type": "text", "sender": "agent", "timestamp": 1703520030000 },
            { "id": "msg-003", "message": "Next Friday, December 29th.", "type": "text", "sender": "user", "timestamp": 1703520090000 },
            { "id": "msg-004", "message": "Great! And when would you like to return?", "type": "text", "sender": "agent", "timestamp": 1703520120000 },
            { "id": "msg-005", "message": "January 5th. Also, I prefer morning flights.", "type": "text", "sender": "user", "timestamp": 1703520180000 },
            { "id": "msg-006", "message": "Perfect! Let me search for morning flights from your location.", "type": "text", "sender": "agent", "timestamp": 1703520210000 },
            { "id": "msg-007", "message": "", "type": "file", "file": { "path": "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400", "fileSize": 245680 }, "sender": "user", "timestamp": 1703520300000 },
            { "id": "msg-008", "message": "Thanks! I see you prefer IndiGo.", "type": "text", "sender": "agent", "timestamp": 1703520330000 },
            { "id": "msg-009", "message": "Here are 3 options.", "type": "file", "file": { "path": "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=400", "fileSize": 189420 }, "sender": "agent", "timestamp": 1703520420000 },
            { "id": "msg-010", "message": "The second option looks perfect!", "type": "text", "sender": "user", "timestamp": 1703520480000 }
        ]
        """
        
        guard let data = jsonString.data(using: .utf8) else { return }
        do {
            let seedMessages = try JSONDecoder().decode([Message].self, from: data)
            self.messages = seedMessages
            saveMessages() // Cache seed data immediately
        } catch {
            print("Seed Data Decode Error: \(error)")
        }
    }
}

// MARK: - FileManager Helper

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
