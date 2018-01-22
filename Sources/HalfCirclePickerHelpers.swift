//
//  HalfCirclePickerHelpers.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 28.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Arithmos

protocol HalfCirclePickerHelpers {
    
    func createKnob(in bounds: CGRect, withRadius radius: CGFloat) -> CAShapeLayer
    func halfCircleMask(in bounds: CGRect, andAngleRange angleRange: ClosedRange<CGFloat>) -> CALayer
    func knobLayerPath(in bounds: CGRect, withRadius radius: CGFloat) -> UIBezierPath
}

extension HalfCirclePickerHelpers {
    func createKnob(in bounds: CGRect, withRadius radius: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = knobLayerPath(in: bounds, withRadius: radius).cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        layer.strokeColor = UIColor.gray.cgColor
        layer.isOpaque = true
        return layer
    }
    
    func halfCircleMask(in bounds: CGRect, andAngleRange angleRange: ClosedRange<CGFloat>) -> CALayer {
        let maskLayer = CAShapeLayer()
        
        let path = UIBezierPath(arcCenter: bounds.center, radius: bounds.width/2.0, startAngle: angleRange.lowerBound, endAngle: angleRange.upperBound, clockwise: true)
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        return maskLayer
    }
    
    func knobLayerPath(in bounds: CGRect, withRadius radius: CGFloat) -> UIBezierPath {
        let dimmension = radius * 2
        return UIBezierPath(ovalIn: CGRect(x: bounds.width - dimmension, y: bounds.center.y - radius, width: dimmension, height: dimmension))
    }
}
