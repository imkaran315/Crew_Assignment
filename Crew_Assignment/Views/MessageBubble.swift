//
//  MessageBubble.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//

import SwiftUI

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    @State private var isZoomed = false
    @Binding var showCopiedToast: Bool
    
    var isUser: Bool { message.sender == .user }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Content
                if message.type == .text {
                    Text(message.message)
                        .padding(12)
                        .background(isUser ? Color.blue : Color(UIColor.systemGray5))
                        .foregroundColor(isUser ? .white : .primary)
                        .cornerRadius(16)
                } else if let file = message.file {
                    // Image File Rendering 
                    VStack(alignment: .leading) {
                        AsyncImageHelper(path: file.thumbnail?.path ?? file.path)
                            .frame(width: 200, height: 150)
                            .cornerRadius(12)
                            .onTapGesture { isZoomed = true }
                        
                        Text(formatFileSize(file.fileSize)) // Size indicator 
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if !message.message.isEmpty {
                            Text(message.message)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(8)
                    .background(isUser ? Color.blue.opacity(0.1) : Color(UIColor.systemGray5))
                    .cornerRadius(16)
                    .fullScreenCover(isPresented: $isZoomed) {
                        ZoomableImageView(path: file.path)
                    }
                }
                
                // Timestamp 
                Text(message.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isUser { Spacer() }
        }
        .contextMenu{
            if message.type == .text{
                Button {
                    UIPasteboard.general.string = message.message
                    withAnimation {
                        showCopiedToast = true
                    }
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

            }
            else{
                // possibly copy image as well
            }
        }
    }
    
    func formatFileSize(_ size: Int) -> String {
        let mb = Double(size) / 1024.0 / 1024.0
        return String(format: "%.1f MB", mb)
    }
}


