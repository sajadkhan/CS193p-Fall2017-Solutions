//
//  ViewController.swift
//  Set
//
//  Created by Sajad on 6/21/18.
//  Copyright © 2018 TPLHolding. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var engine = SetEngine() 
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    
    @IBAction func cardPressed(_ sender: UIButton) {
        engine.selectCard(at: cardButtons.index(of: sender)!)
        updateViewFromModel()
    }
    
    
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        engine.dealThreeMoreCards()
        updateViewFromModel()
    }
    
    
    @IBAction func restartPressed(_ sender: UIButton) {
        engine = SetEngine()
        updateViewFromModel()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(engine.score)"
        dealMoreCardsButton.isHidden =  engine.cardsOnDisplay.count == 24 || engine.deck.count == 0
        for index in engine.cardsOnDisplay.indices {
            displayCard(at: index, isSelected: engine.isCardSelected(at: index))
        }
        clearCards()
    }
    
    private func clearCards() {
        if engine.cardsOnDisplay.count < cardButtons.count {
            for index in engine.cardsOnDisplay.count..<cardButtons.count {
                let button = cardButtons[index]
                button.layer.cornerRadius = 0.0
                button.layer.borderWidth = 0.0
                button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                button.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
            }
        }
    }
    
    private func displayCard(at index: Int, isSelected: Bool) {
        let button = cardButtons[index]
        if isSelected {
            button.layer.cornerRadius = 8.0
            button.layer.borderWidth = 3.0
            button.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        } else {
            button.layer.cornerRadius = 0.0
            button.layer.borderWidth = 0.0
            button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }
        let card = engine.cardsOnDisplay[index]
        configureButton(button, for: card)
    }
    
    private func configureButton(_ button: UIButton, for card: Card) {
        let attributes: [NSAttributedStringKey: Any] = [
            .strokeColor : CardAttributes.colors[card.color]!,
            .strokeWidth : CardAttributes.strokeWidth[card.shading]!,
            .foregroundColor : CardAttributes.colors[card.color]!.withAlphaComponent(CardAttributes.alpha[card.shading]!)
        ]
        
        var title = CardAttributes.shapes[card.symbol]!
        switch card.number {
        case .two:
            title = "\(title)\n\(title)"
        case .three:
            title = "\(title)\n\(title)\n\(title)"
        default:
            break
        }
        button.titleLabel?.numberOfLines = 0
        let attributedTitle = NSAttributedString(string: title, attributes:attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
    }

}

struct CardAttributes {
    static let shapes: [Card.Symbol: String] = [.oval: "●", .diamond: "▲", .squiggle: "■"]
    static let colors: [Card.Color: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .purple: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), .green: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
    static let alpha: [Card.Shade: CGFloat] = [.solid: 1.0, .open: 0.40, .striped: 0.15]
    static let strokeWidth: [Card.Shade: CGFloat] = [.solid: -5, .open: 5, .striped: -5]
}

