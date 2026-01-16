//
//  HelperViews.swift
//  Crew_Assignment
//
//  Created by Karan Verma on 15/01/26.
//

import SwiftUI

// MARK: - Zoomable Image View

struct ZoomableImageView: View {
    let path: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ZoomableContainer {
                AsyncImageHelper(path: path)
                    .aspectRatio(contentMode: .fit)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
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

// MARK: - Zoomable Container

struct ZoomableContainer<Content: View>: View {
    let content: Content

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero

    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(scale * gestureScale)
            .offset(
                x: offset.width + gestureOffset.width,
                y: offset.height + gestureOffset.height
            )
            .gesture(
                MagnificationGesture()
                    .updating($gestureScale) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        scale *= value
                        snapBack()
                    }
                    .simultaneously(
                        with: DragGesture()
                            .updating($gestureOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                offset.width += value.translation.width
                                offset.height += value.translation.height
                                snapBack()
                            }
                    )
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: scale)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: offset)
    }

    private func snapBack() {
        withAnimation {
            scale = 1
            offset = .zero
        }
    }
}

// MARK: - Async Image Helper

struct AsyncImageHelper: View {
    let path: String

    var body: some View {
        if let url = URL(string: path), path.hasPrefix("http") { // to check if it is url or file manager path
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }

        } else if let url = URL(string: path) {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            } else {
                Color.red.opacity(0.3)
            }
        }
    }
}
