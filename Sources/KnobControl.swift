//
//  KnobControl.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 09.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Foundation
import UIKit
import Arithmos
import Bezier
import CoreGraphics
import PocketTool

public class KnobControl: UIView {
    
    typealias AllowedAngleRange = ClosedRange<CGFloat>
    /* Defines the insets of the knob. Defaults to
     * 30 */
    internal var knobInsets: CGFloat = 30    // TODO: change it to percentege
    
    // Layer for the Hue and Saturation wheel
    var backgroundLayer: CALayer!
    var knobLayer: CALayer!
    
    internal var angle: CGFloat = 0 { // TODO: make typealias for angles, or research UnitAngle in Apple's new Measurments API
        didSet {
            knobRotated?(angle)
        }
    }
    internal var knobRotated: ((CGFloat) -> ())?
    internal var allowedAngleRange: AllowedAngleRange!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal init(frame: CGRect, knobInsets: CGFloat, allowedAngleRange: AllowedAngleRange = 0...(2 * .pi)) {
        super.init(frame: frame)
        
        self.allowedAngleRange = allowedAngleRange
        self.knobInsets = knobInsets
        let mask = maskLayer(in: frame)
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.mask = mask
        
        backgroundLayer = createBackgroundLayer(in: self.bounds)
        self.layer.addSublayer(backgroundLayer)
        
        knobLayer = createKnobLayer(in: self.bounds.centralSquare.insetBy(dx: knobInsets, dy: knobInsets))
        self.layer.addSublayer(knobLayer)
        
        angle = layer.bounds.center.normalizedAngle(to: CGPoint(x: 0, y: -1))
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - input handling
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches, withAnimation: false)
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let maskLayer = self.layer.mask as? CAShapeLayer, let maskPath = maskLayer.path else {
            return true
        }
        if maskPath.contains(point) {
            return true
        } else {
            return false
        }
    }
    // MARK: - private helpers
    
    internal func maskLayer(in bounds: CGRect) -> CALayer {
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }
    
    private func handle(touches: Set<UITouch>, withAnimation: Bool = true) {
        guard let touch = touches.first else {
            return
        }
        angle = getAngleFor(touch)
        
        if withAnimation {
            rotateKnob(to: angle)
        }
    }
    
    private func getAngleFor(_ touch: UITouch) -> CGFloat {
        let point = touch.location(in: self)
        return layer.bounds.center.normalizedAngle(to: point).clampedAngle(in: allowedAngleRange)
    }
    
    internal func rotateKnob(to angle: CGFloat, withAnimation: Bool = true) {
        guard let fromAngle = knobLayer.normalizedRotationAngle else {
            return
        }
        
        let toAngle = getDestinationAngle(from: fromAngle, to: angle)
        let animation = CABasicAnimation(for: .rotation, from: fromAngle, to: toAngle, duration: 0.25)
        if withAnimation {
            knobLayer.rotate(to: angle, withAnimation: .custom(animation))
        }
        else {
            knobLayer.rotate(to: angle, withAnimation: .none)
        }
    }
    
    private func getDestinationAngle(from fromAngle: CGFloat, to toAngle: CGFloat) -> CGFloat { // TODO: find better name for this method
        let angleDifference = toAngle - fromAngle
        if angleDifference > .pi {
            return toAngle - .pi * 2
        } else if angleDifference < -.pi {
            return toAngle + .pi * 2
        } else {
            return toAngle
        }
    }
    
    internal func createBackgroundLayer(in bounds: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = bounds
        if bounds.size == CGSize.zero {
            layer.frame = CGRect(origin: bounds.origin, size: CGSize(width: 10.0, height: 10.0))
        }
        layer.isOpaque = true
        return layer
    }
    
    internal func createKnobLayer(in bounds: CGRect) -> CALayer {
        let knob = CALayer()
        let knobBounds = self.bounds.centralSquare.insetBy(dx: knobInsets, dy: knobInsets)
        knob.frame = knobBounds
        knob.isOpaque = true
        return knob
    }
}
