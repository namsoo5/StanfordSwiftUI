//
//  StanfordSwiftUIApp.swift
//  StanfordSwiftUI
//
//  Created by 남수김 on 2021/01/05.
//

import SwiftUI

@main
struct StanfordSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            let game = EmojiMemoryGame()
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
