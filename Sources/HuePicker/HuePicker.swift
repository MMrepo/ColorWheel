//
//  ColorWheel.swift
//  Vindur
//
//  Created by Mateusz on 07.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Arithmos
import UIKit
import Iris
import Bezier
import CoreGraphics
import PocketTool

public class HuePicker: KnobControl {

    private lazy var backgroundLayerImageGenerator:HueCircleImageCreator? = {
        do {
            return try HueCircleImageCreator()
        } catch let error {
            print(error)
            return nil
        }
    }()
    
    public var color: UIColor! {
        return UIColor(hsv: colorHSV)
    }
    
    public var colorHSV: HSV! {
        didSet {
            guard let knobLayer = self.knobLayer as? CAShapeLayer else {
                return
            }
            self.set(color: UIColor(hsv: colorHSV), for: knobLayer)
        }
    }
        
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    public init(frame: CGRect, color: HSV, knobInset: CGFloat = 50.0, hueSelected: @escaping (CGFloat) -> ()) {
        super.init(frame: frame, knobInsets: knobInset)
        self.colorHSV = color
        self.knobRotated = { [unowned self] angle in
            guard let knobLayer = self.knobLayer as? CAShapeLayer else {
                return
            }
            let selectedHue = self.hue(forAngle: angle)
            self.colorHSV.hue = selectedHue
            self.set(color: self.color, for: knobLayer)
            hueSelected(selectedHue)
        }
        
        self.angle = angle(forHue: self.colorHSV.hue)
        self.rotateKnob(to: self.angle, withAnimation: false)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        print("ArithmosVersionNumber: \(ArithmosVersionNumber)")
    }
    
    // MARK: - private helpers
    private func angle(forHue hue: CGFloat) -> CGFloat {
        return hue * 2 * .pi
    }
    
    private func hue(forAngle angle:CGFloat) -> CGFloat {
        return angle / (2 * .pi)
    }
    
    private func set(color: UIColor, for layer: CAShapeLayer) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.fillColor = color.cgColor
        layer.shadowColor = color.complementary.withAlphaComponent(0.8).cgColor
        CATransaction.commit()
    }
    
    // Mark: -- private
    private func makeKnobLayerPath(bounds:CGRect, knobSide: CGFloat) -> UIBezierPath {
        // TODO: In future I would like to load paths from external source
        let cornerRadius:CGFloat = 4.0
        let rectangle = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: knobSide, height: knobSide), cornerRadius: cornerRadius)
        let path = UIBezierPath(ovalIn: bounds)
        
        let transform = CGAffineTransform(rotationAngle: CGFloat.pi/4.0)
        let moveToEdge = CGAffineTransform(translationX: bounds.center.x, y: 2 * bounds.origin.y/3 )
        rectangle.apply(transform)
        rectangle.apply(moveToEdge)
        rectangle.append(path)
        
        rectangle.usesEvenOddFillRule = false
        rectangle.rotate(with: .pi / 2.0)
        return rectangle
    }
    
    private func createKnob(in bounds: CGRect)  -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = bounds
        let knobSide:CGFloat = bounds.origin.y/2
        layer.path = makeKnobLayerPath(bounds: bounds, knobSide: knobSide).cgPath
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 10.0
        layer.isOpaque = true
        return layer
    }
    
    override func createKnobLayer(in bounds: CGRect) -> CALayer {
        return createKnob(in: bounds)
    }
    
    override func createBackgroundLayer(in bounds: CGRect) -> CALayer {
        let backgroundLayer = super.createBackgroundLayer(in: bounds)
        backgroundLayer.isOpaque = true
        backgroundLayer.contents = backgroundLayerImageGenerator?.cgImage(withFrame: bounds)
        return backgroundLayer
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = self.bounds
        backgroundLayer.contents = backgroundLayerImageGenerator?.cgImage(withFrame: bounds)

        guard let maskLayer = self.layer.mask as? CAShapeLayer, let oldCGPath = maskLayer.path else {
            return
        }

        let newPath = UIBezierPath(cgPath: oldCGPath)
        maskLayer.path = newPath.fit(into: self.bounds).cgPath

        let knobBounds = self.bounds.centralSquare.insetBy(dx: knobInsets, dy: knobInsets)
        let transform = knobLayer.transform

        knobLayer.transform = CATransform3DIdentity
        knobLayer.frame = self.bounds

        if let knobLayerShape = knobLayer as? CAShapeLayer {
            let newKnobPath = UIBezierPath(cgPath: knobLayerShape.path!).fit(into: knobBounds)

            let knobSize = newKnobPath.cgPath.boundingBox.size
            let offset = (knobSize.height - knobSize.width)/2
            knobLayerShape.path = newKnobPath.moveCenter(by: CGVector(dx: -offset, dy: 0)).cgPath
        }

        knobLayer.transform = transform

        CATransaction.commit()
    }
}
