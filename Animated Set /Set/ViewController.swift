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
    private var cardGrid = Grid(layout: Grid.Layout.aspectRatio(0.75))
    
    @IBOutlet weak var gameView: UIView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCards))
            swipe.direction = [.left, .right]
            gameView.addGestureRecognizer(swipe)
            
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
            gameView.addGestureRecognizer(rotateGesture)
        }
    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    
    @objc func selectCard(byHandlingGestureRecognizer recognizer :UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            engine.selectCard(at: gameView.subviews.index(of: recognizer.view!)!)
            updateViewFromModel()
        default:
            break
        }
    }
    
    @objc func shuffleCards(byHandlingGestureRecognizer recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            engine.shuffleCardsOnDislpay()
            updateViewFromModel()
        default:
            break
        }
    }
    
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        dealMoreCards()
    }
    
    @objc func dealMoreCards() {
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
        dealMoreCardsButton.isHidden = engine.deck.count == 0
        refreshCardsOnDisplay()
    }
    
    private func refreshCardsOnDisplay() {
        cardGrid.cellCount = engine.cardsOnDisplay.count
        for view in gameView.subviews {
            view.removeFromSuperview()
        }
        for index in engine.cardsOnDisplay.indices {
            displayCard(at: index, isSelected: engine.isCardSelected(at: index))
        }
    }
    
    private func displayCard(at index: Int, isSelected: Bool) {
        
        let card = engine.cardsOnDisplay[index]
        if let cardFrame = cardGrid[index] {
            let cardFrameWithInsets = cardFrame.insetBy(dx: 10.0, dy: 10.0)
            let cardView = CardView(frame: cardFrameWithInsets)
            cardView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            cardView.color = CardAttributes.colors[card.color]!
            cardView.symbol = card.symbol.rawValue
            cardView.number = card.number.rawValue
            cardView.shade = card.shading.rawValue
            
            if isSelected {
                cardView.layer.borderWidth = 3.0
                cardView.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            } else {
                cardView.layer.borderWidth = 0.0
                cardView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(byHandlingGestureRecognizer:)))
            cardView.addGestureRecognizer(tap)
            
            gameView.addSubview(cardView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardGrid.frame = gameView.bounds
        refreshCardsOnDisplay()
    }

}

struct CardAttributes {
    static let colors: [Card.Color: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .purple: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), .green: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
}

