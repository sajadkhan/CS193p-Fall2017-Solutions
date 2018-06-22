//
//  Card.swift
//  Set
//
//  Created by Sajad on 6/21/18.
//  Copyright © 2018 TPLHolding. All rights reserved.
//

import Foundation

struct Card {
    enum Shade: Int {
        case solid
        case striped
        case open
        static let allCases: [Shade] = [.solid, .striped, .open]
    }
    
    enum Symbol: Int {
        case diamond
        case squiggle
        case oval
        static let allCases: [Symbol] = [.diamond, .squiggle, .oval]
    }
    
    enum Color: Int {
        case red
        case green
        case purple
        static let allCases: [Color] = [.red, .green, .purple]
    }
    
    enum Number: Int {
        case one
        case two
        case three
        static let allCases: [Number] = [.one, .two, .three]
    }
    
    let number: Number
    let shading: Shade
    let symbol: Symbol
    let color: Color
}

extension Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.color == rhs.color &&
            lhs.number == rhs.number &&
            lhs.shading == rhs.shading &&
            lhs.symbol == rhs.symbol
    }
}

