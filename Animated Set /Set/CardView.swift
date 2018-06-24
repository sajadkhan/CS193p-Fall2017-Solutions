//
//  CardView.swift
//  Set
//
//  Created by Sajad on 6/23/18.
//  Copyright © 2018 TPLHolding. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {

    @IBInspectable var shade: String = "squiggle" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var symbol: String = "oval" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var color: UIColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var number: Int = 3 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    var isSelected = false {
        didSet {
            self.layer.cornerRadius = cornerRadius
            if isSelected {
                self.layer.borderWidth = 3.0
                self.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            } else {
                self.layer.borderWidth = 0.0
                self.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let cardColor = !isFaceUp ? UIColor.darkGray : .white
        let roundRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundRect.addClip()
        cardColor.setFill()
        roundRect.fill()
        
        if isFaceUp {
            let originsToDraw = calculateOriginsToDraw(forSymbolCount: number)
            
            var drawingMethod: ((CGPoint) -> Void)?
            
            switch symbol {
            case "oval":
                drawingMethod = drawOval(at:)
            case "diamond":
                drawingMethod = drawDiamond(at:)
            case "squiggle":
                drawingMethod = drawSquiggle(at:)
            default:
                break
            }
            
            if let drawingMethod = drawingMethod {
                for origin in originsToDraw {
                    drawingMethod(origin)
                }
            }
        }
        
    }
    
    
    private func calculateOriginsToDraw(forSymbolCount count: Int) -> [CGPoint] {
        var origins = [CGPoint]()
        let center = bounds.center
        let symbolCountAboveCenter: Int = count/2
        var centerYOfFirst: CGFloat
        
        if (count % 2) != 0 {
            centerYOfFirst = center.y - ( CGFloat(symbolCountAboveCenter) * (shapeHeight + spaceBetweenShapes) )
        } else {
            centerYOfFirst = center.y - ( CGFloat(symbolCountAboveCenter) * (shapeHeight + spaceBetweenShapes) - (0.5 * (shapeHeight + spaceBetweenShapes)))
        }
        
        let firstSymbolCenter = CGPoint(x: center.x, y: centerYOfFirst)
        
        var currentDrawingShapeCenter = firstSymbolCenter
        for _ in 0..<count {
            let originToDraw = CGPoint(x: (currentDrawingShapeCenter.x - shapeWidth/2),
                                       y: (currentDrawingShapeCenter.y - shapeHeight/2))
            origins += [originToDraw]
            currentDrawingShapeCenter = CGPoint(x: currentDrawingShapeCenter.x,
                                    y: currentDrawingShapeCenter.y + (shapeHeight + spaceBetweenShapes))
            
        }
        return origins
    }
    

    
    private func drawOval(at origin: CGPoint) {
        let path = UIBezierPath(roundedRect: CGRect(origin: origin, size: shapeSize), cornerRadius: cornerRadiusForOvalShape)
        applyShadingAndColor(to: path)
    }
    
    private func drawDiamond(at origin: CGPoint) {
        let pathBounds = CGRect(origin: origin, size: shapeSize)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: pathBounds.minX, y: pathBounds.midY))
        path.addLine(to: CGPoint(x: pathBounds.midX, y: pathBounds.minY))
        path.addLine(to: CGPoint(x: pathBounds.maxX, y: pathBounds.midY))
        path.addLine(to: CGPoint(x: pathBounds.midX, y: pathBounds.maxY))
        path.close()
        applyShadingAndColor(to: path)
    }
    
    private func drawSquiggle(at origin: CGPoint) {
        let pathBounds = CGRect(origin: origin, size: shapeSize)
        let path = UIBezierPath()
       
        let offset = CGPoint(x: pathBounds.size.width/4, y: pathBounds.size.height/4)
        path.move(to: CGPoint(x: pathBounds.minX, y: pathBounds.maxY))
        path.addLine(to: CGPoint(x: pathBounds.minX + offset.x, y: pathBounds.minY + offset.y))
        path.addLine(to: CGPoint(x: pathBounds.maxX, y: pathBounds.minY))
        path.addLine(to: CGPoint(x: pathBounds.maxX - offset.x, y: pathBounds.maxY - offset.y))
        path.close()
        applyShadingAndColor(to: path)
    }
    
    private func applyShadingAndColor(to path: UIBezierPath) {
        color.setStroke()
        path.stroke()
        
        switch shade {
        case "solid":
            color.setFill()
            path.fill()
        case "striped":
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()
                
                path.addClip()
                path.lineWidth = Constants.lineWidthForStripsOfStripedCard
                
                var currentStripOrigin = CGPoint(x: path.bounds.minX, y: path.bounds.minY)
                while path.bounds.contains(currentStripOrigin) {
                    path.move(to: currentStripOrigin)
                    path.addLine(to: CGPoint(x: currentStripOrigin.x, y: path.bounds.maxY))
                    currentStripOrigin.x += Constants.pointsBetweenStripsOfStripedCard
                }
                color.setStroke()
                path.stroke()
                context.restoreGState()
            }
        default:
            break
        }

    }

}

extension CardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let shapeSizeToBoundsHeight: CGFloat = 0.13
        static let spaceBetweenShapesCardsToBoundsHeight: CGFloat = 0.15
        static let aspectRatioForShape: CGFloat = 2.5
        static let cornerRadiusForOvalShapeToItsHeight: CGFloat = 0.45
    }
    
    private struct Constants {
        static let pointsBetweenStripsOfStripedCard: CGFloat = 5.0
        static let lineWidthForStripsOfStripedCard: CGFloat = 2.0
    }

    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var shapeHeight: CGFloat {
        return bounds.size.height * SizeRatio.shapeSizeToBoundsHeight
    }
    private var shapeWidth: CGFloat {
        return self.shapeHeight * SizeRatio.aspectRatioForShape
    }
    private var shapeSize: CGSize {
        return CGSize(width: shapeWidth, height: shapeHeight)
    }
    private var cornerRadiusForOvalShape: CGFloat {
        return shapeHeight * SizeRatio.cornerRadiusForOvalShapeToItsHeight
    }
    private var spaceBetweenShapes: CGFloat {
        return bounds.size.height * SizeRatio.spaceBetweenShapesCardsToBoundsHeight
    }
    
}


extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}


extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
