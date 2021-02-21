//
//  ContentView.swift
//  EmojiArt
//
//  Created by 남수김 on 2021/02/14.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    private let defaultEmojiSize: CGFloat = 40
    // MARK: - ZoomGesture Properties
    @State private var steadyStatezoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomSacle: CGFloat = 1.0
    private var zoomScale: CGFloat {
        steadyStatezoomScale * gestureZoomSacle
    }
    // MARK: - PanGesture Properties
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: defaultEmojiSize))
                            .onDrag { return NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
            .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: [.image, .text], isTargeted: nil) { providers, location in
                    // location: drop위치
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2,
                                       y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width,
                                       y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / zoomScale,
                                       y: location.y / zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                
            }
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    // MARK: - ZoomGesture
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image,
           image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            steadyStatezoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomSacle) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStatezoomScale *= finalGestureScale
            }
    }
    
    // MARK: - PanGesture
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transcation in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
                print(latestDragGestureValue.translation / self.zoomScale)
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
}
