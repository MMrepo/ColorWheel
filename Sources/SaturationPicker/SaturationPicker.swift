//
//  SaturationPicker.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 19.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import UIKit
import Arithmos
import Iris
import Bezier
import CoreGraphics
import PocketTool

public class SaturationPicker: KnobControl, HalfCirclePickerHelpers {

    private lazy var backgroundLayerImageGenerator:SaturationHalfCircleImageCreator? = {
        do {
            return try SaturationHalfCircleImageCreator()
        } catch let error {
            print(error)
            return nil
        }
    }()
    
    public var hue: CGFloat! {
        didSet {
            updateBackground()
        }
    }
    
    public var saturation: CGFloat!
    private var knobRadius: CGFloat = 15
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    public init(frame: CGRect, color: UIColor, knobInset: CGFloat = 15, colorSelected: @escaping (UIColor) -> ()) {
        super.init(frame: frame, knobInsets: knobInset, allowedAngleRange:(.pi/2.0)...(3 * .pi/2.0))
        self.hue = color.hsv.hue
        self.knobRadius = knobInset
        self.knobInsets = 0
        updateBackground()
        self.saturation = color.hsv.saturation
        self.knobRotated = { [unowned self] angle in
            let selectedColor = self.color(forAngle: angle)
            self.saturation = selectedColor.hsv.saturation
            colorSelected(selectedColor)
        }
        
        self.angle = angle(forColor: color)
        self.rotateKnob(to: self.angle, withAnimation: false)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - private helpers
    private func updateBackground() {
        backgroundLayerImageGenerator?.hue = hue
        backgroundLayer.contents = backgroundLayerImageGenerator?.cgImage(withFrame:self.bounds)
    }
    
    private func angle(forColor color: UIColor) -> CGFloat {
        let saturation = color.hsv.saturation
        let angle = (0...1).remap(saturation, in: allowedAngleRange)
        return angle
    }
    
    private func color(forAngle angle:CGFloat) -> UIColor {
        let saturation = allowedAngleRange.remap(angle, in: 0...1)
        return UIColor(hue: self.hue, saturation: saturation, brightness: 1, alpha: 1)
    }
    
    // Mark: -- ovrriden methods
    override func createKnobLayer(in bounds: CGRect) -> CALayer {
        return createKnob(in: bounds, withRadius: knobRadius)
    }
    
    override func maskLayer(in bounds: CGRect) -> CALayer {
        return halfCircleMask(in: bounds, andAngleRange: allowedAngleRange)
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        backgroundLayer.frame = self.bounds
        guard let knobLayer = self.knobLayer as? CAShapeLayer else {
            return
        }

        self.layer.mask = maskLayer(in: self.bounds)
        self.rotateKnob(to: 0, withAnimation: false)
        knobLayer.frame = self.bounds
        knobLayer.path = knobLayerPath(in: bounds, withRadius: knobRadius).cgPath
        self.rotateKnob(to: self.angle, withAnimation: false)
    }
}
