//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by 남수김 on 2021/02/14.
//

import Foundation

// Model
struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    var uniqueEmojiId = 0
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init() { }
    init?(json: Data?) {
        if json != nil,
           let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int // offset from center
        var y: Int // offset from center
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
