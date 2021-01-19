//
//  EmojiMemoryGame.swift
//  StanfordSwiftUI
//
//  Created by 남수김 on 2021/01/11.
//

import SwiftUI

// ViewModel
// 힙에 있기 때문에 공유하기 쉽다는것이 큰장점
// 포인터가 있기때문에 모든 뷰는 그것에 대한 포인터를 가질수 있음
// 많은 뷰가 이 포털을 통해서 모델을 보고싶을것
// 모든뷰를 공유하려면 각각에대한 포인터를 이용해야하기때문에
// 동일한 뷰모델을 가르키는 클래스로 구현함

//func createCardContent(pairIndex: Int) -> String {
//    return "😀"
//}

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis: [String] = ["👻", "🎃"]
        return MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    // MARK: - Access to the Model
    
    var cards: [MemoryGame<String>.Card] {
        model.cards
    }
    
    // MARK: - Intent(s)
    
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
