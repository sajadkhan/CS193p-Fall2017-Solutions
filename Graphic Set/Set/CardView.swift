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

    @IBInspectable var shade: String = "striped" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var symbol: String = "oval" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var color: String = "green" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var number: Int = 3 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    override func draw(_ rect: CGRect) {
        let roundRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundRect.addClip()
        UIColor.white.setFill()
        roundRect.fill()
        drawSymbols()
    }
    
    
    private func drawSymbols() {
        let center = bounds.center
        let symbolCountAboveCenter: Int = number/2
        var centerYOfFirst: CGFloat
        
        if (number % 2) != 0 {
            centerYOfFirst = center.y - ( CGFloat(symbolCountAboveCenter) * (shapeHeight + spaceBetweenShapes) )
        } else {
            centerYOfFirst = center.y - ( CGFloat(symbolCountAboveCenter) * (shapeHeight + spaceBetweenShapes) - (0.5 * (shapeHeight + spaceBetweenShapes)))
        }
        
        let firstSymbolCenter = CGPoint(x: center.x, y: centerYOfFirst)
        
        var currentDrawingShapeCenter = firstSymbolCenter
        for _ in 0..<number {
            drawSymbolWith(centerAt: currentDrawingShapeCenter)
            currentDrawingShapeCenter = CGPoint(x: currentDrawingShapeCenter.x,
                                    y: currentDrawingShapeCenter.y + (shapeHeight + spaceBetweenShapes))
        }
        
        
    }
    
    private func drawSymbolWith(centerAt center: CGPoint) {
        switch symbol {
        case "oval":
            drawOval(with: center)
        default:
            break
        }
    }
    
    private func drawOval(with center: CGPoint) {
        let originToDraw = CGPoint(x: (center.x - shapeWidth/2),
                                   y: (center.y - shapeHeight/2))
    
        let path = UIBezierPath(roundedRect: CGRect(origin: originToDraw, size: shapeSize), cornerRadius: cornerRadiusForOvalShape)
        
        applyShadingAndColor(to: path)
    }
    
    
    private func applyShadingAndColor(to path: UIBezierPath) {
        
        let color = UIColor.colorFromString(self.color)!
        color.setStroke()
        path.stroke()
        
        if shade == "fill" {
            color.setFill()
            path.fill()
        } else if shade == "striped" {
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

extension UIColor {
    static func colorFromString(_ string: String) -> UIColor? {
        switch string {
        case "green":
            return UIColor.green
        case "red":
            return UIColor.red
        case "purple":
            return UIColor.purple
        default:
            return nil
        }
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
