//
//  SetEngine.swift
//  Set
//
//  Created by Sajad on 6/21/18.
//  Copyright © 2018 TPLHolding. All rights reserved.
//

import Foundation

struct SetEngine {
    private(set) lazy var deck: [Card] = {
        var cards = [Card]()
        for number in Card.Number.allCases {
            for shade in Card.Shade.allCases {
                for color in Card.Color.allCases {
                    for symbol in Card.Symbol.allCases {
                        let card = Card(number: number,
                                        shading: shade,
                                        symbol: symbol,
                                        color: color)
                        cards.append(card)
                    }
                }
            }
        }
        return cards
    }()
    
    private(set) var selectedCards = [Card]()
    private(set) var cardsOnDisplay = [Card]()
    private(set) var score = 0
    
    func isCardSelected(at index: Int) -> Bool {
        return selectedCards.contains(where: { $0 == cardsOnDisplay[index] })
    }
    
    mutating func shuffleCardsOnDislpay() {
        var onDisplay = cardsOnDisplay
        var shuffled = [Card]()
        while onDisplay.count > 0 {
            shuffled += [onDisplay.remove(at: onDisplay.randomIndex)]
        }
        cardsOnDisplay = shuffled
    }
    
    mutating func selectCard(at index: Int) {
        if cardsOnDisplay.count <= index {
            return
        }
        let card = cardsOnDisplay[index]
        if !selectedCards.contains(where: { $0 == card }) {
            if selectedCards.count == 3 {
                if checkIfIsASet(cards: selectedCards) {
                    removeTheMatchingSet()
                    score += 1
                } else {
                    selectedCards.removeAll()
                    selectedCards.append(card)
                    score -= 1
                }
            } else {
                selectedCards.append(card)
            }
        } else {
            selectedCards.remove(at: selectedCards.index(of: card)!)
        }
    }
    
    private mutating func removeTheMatchingSet() {
        for card in selectedCards {
            if let index = cardsOnDisplay.index(of: card) {
                cardsOnDisplay.remove(at: index)
            }
        }
        selectedCards.removeAll()
        dealCards(3)
    }
    
    private func checkIfIsASet(cards: [Card]) -> Bool {
        let numbers = Set(cards.map { $0.number }).count
        let shades = Set(cards.map { $0.shading }).count
        let colors = Set(cards.map { $0.color }).count
        let symbols = Set(cards.map { $0.symbol }).count
        return numbers != 2 && shades != 2 && colors != 2 && symbols != 2
    }

    
    private mutating func fetchNextCardFromDeck() -> Card {
        assert(deck.count > 0, "SetEngine.fetchNextCardFromDeck(): CardDeck is empty")
        let card = deck.remove(at: deck.randomIndex)
        return card
    }
    
    mutating func dealThreeMoreCards() {
        if selectedCards.count == 3,
            checkIfIsASet(cards: selectedCards) {
            removeTheMatchingSet()
        } else {
            dealCards(3)
        }
    }
    
    mutating private func dealCards(_ count: Int) {
        var cards = [Card]()
        if deck.count > 0 {
            for _ in 0..<count {
                cards.append(fetchNextCardFromDeck())
            }
        }
        cardsOnDisplay += cards
    }
    
    init() {
        dealCards(12)
    }
    
}

extension Array {
    var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(count - 1)))
    }
}
