//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by 남수김 on 2021/02/26.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @Binding var chosenPalette: String
    @EnvironmentObject var document: EmojiArtDocument
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: {
                        Text("Done").padding()
                    })
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")) {
                    let column: [GridItem] = Array(repeating: GridItem(.flexible()), count: 6)
                    ScrollView {
                        LazyVGrid(columns: column) {
                            ForEach(chosenPalette.map{ String($0) }, id: \.self) { emoji in
                                Text(emoji)
                                    .font(Font.system(size: self.fontSize))
                                    .onTapGesture {
                                        self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                                    }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }
    
    // MARK: - Drawing Constants
    
    let fontSize: CGFloat = 40
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
