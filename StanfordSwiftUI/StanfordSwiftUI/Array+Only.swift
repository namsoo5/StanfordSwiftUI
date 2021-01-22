//
//  Array+Only.swift
//  StanfordSwiftUI
//
//  Created by 남수김 on 2021/01/22.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
