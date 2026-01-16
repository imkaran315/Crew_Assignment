//
//  HelperViews.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//

import SwiftUI

// MARK: - Helper Views

struct ZoomableImageView: View {
    let path: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AsyncImageHelper(path: path)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct AsyncImageHelper: View {
    let path: String
    
    var body: some View {
        if let url = URL(string: path), path.hasPrefix("http") {
            // Remote Image (Seed data)
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
        } else if let url = URL(string: path) {
            // Local File (User captured)
            if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.red.opacity(0.3) // Error state
            }
        }
    }
}


