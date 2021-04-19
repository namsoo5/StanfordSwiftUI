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
    
    @GestureState private var gestureZoomSacle: CGFloat = 1.0
    private var zoomScale: CGFloat {
        document.steadyStatezoomScale * gestureZoomSacle
    }
    // MARK: - PanGesture Properties
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    if isLoading {
                        Image(systemName: "timer").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
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
            .navigationBarItems(leading: self.pickImage, trailing: Button(action: {
                if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                    self.comfirmBackgroundPaste = true
                } else {
                    explainBackgroundPaste = true
                }
            }, label: {
                Image(systemName: "doc.on.clipboard").imageScale(.large)
                    .alert(isPresented: self.$explainBackgroundPaste) {
                        return Alert(title: Text("Paste Background"),
                                     message: Text("복사 해오세요~"),
                                     dismissButton: .default(Text("OK"))
                        )
                    }
            }))
            .zIndex(-1)
        }
        .alert(isPresented: self.$comfirmBackgroundPaste) {
            return Alert(title: Text("Paste Background"),
                         message: Text("paste error \(UIPasteboard.general.url?.absoluteString ?? "nothing")"),
                         primaryButton: .default(Text("OK")) {
                            self.document.backgroundURL = UIPasteboard.general.url
                         },
                         secondaryButton: .cancel()
            )
        }
    }
    @State private var showImagePicker = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    
    private var pickImage: some View {
        HStack {
            Image(systemName: "photo").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                self.showImagePicker = true
                self.imagePickerSourceType = .photoLibrary
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Image(systemName: "camera").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                    self.showImagePicker = true
                    self.imagePickerSourceType = .camera
                }
            }
        }.sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: self.imagePickerSourceType) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        self.document.backgroundURL = image?.storeInFilesystem()
                    }
                }
                self.showImagePicker = false
            }
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var comfirmBackgroundPaste = false
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
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
           image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStatezoomScale = min(hZoom, vZoom)
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
                document.steadyStatezoomScale *= finalGestureScale
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
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
}
