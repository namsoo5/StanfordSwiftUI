//
//  Array+Identifiable.swift
//  StanfordSwiftUI
//
//  Created by 남수김 on 2021/01/22.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
