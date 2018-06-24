//
//  ViewController.swift
//  Set
//
//  Created by Sajad on 6/21/18.
//  Copyright © 2018 TPLHolding. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardDeckView: UIView!
    @IBOutlet weak var dealtCardView: UIView!
    
    private var engine = SetEngine()
    private var cardGrid = Grid(layout: Grid.Layout.aspectRatio(0.75))
    private var selectedCardViews = [CardView]()
    private var displayedCards = [CardView]()
    
    private lazy var animator = UIDynamicAnimator(referenceView: gameView)
    private lazy var cardBehaviour = CardBehaviour(in: animator)

    
    @IBOutlet weak var gameView: UIView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealMoreCards))
            swipe.direction = [.left, .right]
            gameView.addGestureRecognizer(swipe)
            
            /*
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
            gameView.addGestureRecognizer(rotateGesture)
             */
        }
    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    
    @objc func selectCard(byHandlingGestureRecognizer recognizer :UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view as? CardView {
                
                if cardView.isSelected {
                    cardView.isSelected = false
                    selectedCardViews.remove(at: selectedCardViews.index(of: cardView)!)
                } else {
                    cardView.isSelected = true
                    selectedCardViews.append(cardView)
                }
                
                if engine.selectCard(at: displayedCards.index(of: cardView)!) {
                    
                    for cardView in selectedCardViews {
                        
                        let indexToReplace = displayedCards.index(of: cardView)!
                        
                        if engine.cardsOnDisplay.indices.contains(indexToReplace) {
                            var cardViews = [CardView]()
                            if let cardView = makeCardView(with: engine.cardsOnDisplay[indexToReplace],
                                                           forIndex: indexToReplace) {
                                cardViews += [cardView]
                                displayedCards[indexToReplace] = cardView
                            }
                            flyIn(cardViews)
                        } else {
                            displayedCards.remove(at: indexToReplace)
                        }
                    }
                    
                    flyaway(cards: selectedCardViews)
                    selectedCardViews.removeAll()
                    updateViewFromModel()
                    
                } else {
                    if selectedCardViews.count == 3 {
                        let cards = selectedCardViews
                        cards.forEach { cardView in
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1,
                                                                                delay: 0.0,
                                                                                options: [],
                                                                                animations: {
                                                                                    cardView.transform = cardView.transform.rotated(by: CGFloat.pi/8)
                            }, completion: { finished in
                                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                                               delay: 0.0,
                                                                               options: [],
                                                                               animations: {
                                                                                cardView.transform = cardView.transform.rotated(by: -2*CGFloat.pi/8)
                                }, completion: { finished in
                                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1,
                                                                                   delay: 0.0,
                                                                                   options: [],
                                                                                   animations: {
                                                                                    cardView.transform = CGAffineTransform.identity
                                    }, completion: { finished in
                                        cardView.isSelected = false
                                    })
                                })
                            })
                        }
                        selectedCardViews.removeAll()
                        updateViewFromModel()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    @objc func dealMoreCards() {
        engine.dealThreeMoreCards()
        if displayedCards.count < engine.cardsOnDisplay.count {
            let newCards = engine.cardsOnDisplay[engine.cardsOnDisplay.count-3..<engine.cardsOnDisplay.count]
            cardGrid.cellCount = displayedCards.count + newCards.count
            
            displayedCards.forEach { (cardView) in
                let index = displayedCards.index(of: cardView)!
                if let frame = cardGrid[index] {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                                   delay: 0.0,
                                                                   options: [],
                                                                   animations: {
                                                                    cardView.frame = frame.insetBy(dx: Constants.cardViewFrameInsetValue, dy: Constants.cardViewFrameInsetValue)
                    })
                }
            }
            
            let cardViews: [CardView] = newCards.map { return makeCardView(with: $0, forIndex: self.engine.cardsOnDisplay.index(of: $0)!)! }
            flyIn(cardViews)
            displayedCards += cardViews
        }
    }
    
    private func flyaway(cards: [CardView]) {
        cards.forEach {
            $0.isSelected = false
            cardBehaviour.addItem($0)
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (timer) in
            cards.forEach { (cardView) in
                self.cardBehaviour.removeItem(cardView)
                cardView.transform = CGAffineTransform.identity
                
                let snapTo = self.gameView.convert(self.dealtCardView.bounds.center, from: self.dealtCardView)
                let snapBehavior =  UISnapBehavior(item: cardView, snapTo: snapTo)
                self.animator.addBehavior(snapBehavior)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1.0,
                                                               delay: 0.0,
                                                               options: [],
                                                               animations: {
                                                                let frame = self.gameView.convert(self.dealtCardView.bounds, from: self.dealtCardView)
                                                                
                                                                cardView.frame.size = frame.size
                })
            }
        })
        
        
    }
    
    private func flyIn(_ cards: [CardView]) {
        cards.forEach { (cardView) in
            gameView.addSubview(cardView)
            
            let orignalFrame = cardView.frame
            cardView.frame = gameView.convert(cardDeckView.bounds, from: cardDeckView)
            cardView.isFaceUp = false
            
            let index = cards.index(of: cardView)!
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Double(cards.count - index) * 0.15,
                                                           delay: Double(index) * 0.17,
                                                           options: [],
                                                           animations: {
                                                            cardView.frame = orignalFrame
            }, completion: { finished in
                UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        cardView.isFaceUp = true
                })
            })
            
        }
    }
    
    private func updateViewFromModel() {
        scoreLabel.text = "Score: \(engine.score)"
        dealMoreCardsButton.isHidden = engine.deck.count == 0
    }
    
    
    /*
    @objc func shuffleCards(byHandlingGestureRecognizer recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            engine.shuffleCardsOnDislpay()
            updateViewFromModel()
        default:
            break
        }
    }*/
    
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        dealMoreCards()
    }
    
    
    @IBAction func restartPressed(_ sender: UIButton) {
        engine = SetEngine()
        refreshCards()
        updateViewFromModel()
    }
    
    func refreshCards() {
        displayedCards.removeAll()
        cardGrid.frame = gameView.bounds
        for view in gameView.subviews {
            view.removeFromSuperview()
        }
        addAllCardsFromModelToDisplay()
    }

    
    private func addAllCardsFromModelToDisplay() {
        cardGrid.cellCount = engine.cardsOnDisplay.count
        var cardViews = [CardView]()
        for index in engine.cardsOnDisplay.indices {
            if let cardView = makeCardView(with: engine.cardsOnDisplay[index], forIndex: index) {
                cardViews += [cardView]
            }
        }
        flyIn(cardViews)
        displayedCards += cardViews
    }
    
    private func makeCardView(with card: Card, forIndex index: Int) -> CardView? {
        let card = engine.cardsOnDisplay[index]
        if let cardFrame = cardGrid[index] {
            let cardFrameWithInsets = cardFrame.insetBy(dx: Constants.cardViewFrameInsetValue, dy: Constants.cardViewFrameInsetValue)
            let cardView = CardView(frame: cardFrameWithInsets)
            cardView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            cardView.color = CardAttributes.colors[card.color]!
            cardView.symbol = card.symbol.rawValue
            cardView.number = card.number.rawValue
            cardView.shade = card.shading.rawValue
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCard(byHandlingGestureRecognizer:)))
            cardView.addGestureRecognizer(tap)
            
            return cardView
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardGrid.frame = gameView.bounds
        addAllCardsFromModelToDisplay()
        animator.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if gameView.bounds != cardGrid.frame {
            cardGrid.frame = gameView.bounds
            if displayedCards.count > 0 {
                for card in displayedCards {
                    let index = displayedCards.index(of: card)!
                    if let frame = cardGrid[index] {
                        card.frame = frame.insetBy(dx: Constants.cardViewFrameInsetValue, dy: Constants.cardViewFrameInsetValue)
                    }
                }
            }
            
        }
    }
    
    
    struct Constants {
        static let cardViewFrameInsetValue = CGFloat(10.0)
    }

}

struct CardAttributes {
    static let colors: [Card.Color: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .purple: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), .green: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
}

extension ViewController: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        let dynamicItems = animator.items(in: gameView.convert(view.bounds, from: view))
        dynamicItems.forEach { (dynamicItem) in
            if let cardView = dynamicItem as? CardView {
                UIView.transition(
                    with: cardView,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        cardView.isFaceUp = false
                }, completion: { finished in
                    cardView.removeFromSuperview()
                })
            }
        }
    }
}
