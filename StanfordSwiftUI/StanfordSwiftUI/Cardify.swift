//
//  Cardify.swift
//  StanfordSwiftUI
//
//  Created by 남수김 on 2021/01/27.
//

import SwiftUI

struct Cardify: ViewModifier {
    var isFaceUp: Bool
    
    // 호출한 뷰가 content로 들어옴(여기서는 ZStack이 들어옴)
    func body(content: Content) -> some View {
        ZStack {
            if isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill()
                    .foregroundColor(.white)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: edgeLineWidth)
                content
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill()
            }
        }
    }
    
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
