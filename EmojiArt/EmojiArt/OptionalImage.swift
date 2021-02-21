//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by 남수김 on 2021/02/21.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
