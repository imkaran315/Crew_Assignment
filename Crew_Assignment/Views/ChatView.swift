//
//  ChatView.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//

import SwiftUI

// MARK: - Main Chat View
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText: String = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var inputImage: UIImage?
    @State private var showCopiedToast = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Message List 
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message, showCopiedToast: $showCopiedToast)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    // Scroll to bottom on load 
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.messages) { _,_ in
                    // Scroll to bottom on new message
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input Area 
            HStack(alignment: .bottom) {
                // Attachment Button
                Menu {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Label("Photo Library", systemImage: "photo")
                    }
                    
                    Button(action: {
                        showCamera = true
                    }) {
                        Label("Camera", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }

                // Text Input
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .lineLimit(1...5)

                // Send Button 
                Button(action: {
                    viewModel.sendMessage(text: inputText)
                    inputText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(inputText.isEmpty ? .gray : .blue)
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
        .navigationBarTitle("Support Agent", displayMode: .inline)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: {
            if let img = inputImage {
                viewModel.sendImage(image: img)
                inputImage = nil
            }
        }) {
            ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
                .ignoresSafeArea()

        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: {
            if let img = inputImage {
                viewModel.sendImage(image: img)
                inputImage = nil
            }
        }) {
            ImagePicker(selectedImage: $inputImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .overlay(copiedToast)
    }
    
// MARK: - subviews
    
    private var copiedToast: some View {
        Group {
            if showCopiedToast {
                Text("Message copied")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showCopiedToast = false
                            }
                        }
                    }
                    .offset(y: -40)
            }
        }
    }
}
