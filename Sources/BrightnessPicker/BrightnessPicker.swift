//
//  BrightnessPicker.swift
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

public class BrightnessPicker: KnobControl, HalfCirclePickerHelpers {
    
    private lazy var backgroundLayerImageGenerator:BrightnessHalfCircleImageCreator? = {
        do {
            return try BrightnessHalfCircleImageCreator()
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
    
    public var brightness: CGFloat!
    private var knobRadius: CGFloat = 15

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    public init(frame: CGRect, color: UIColor, knobInset: CGFloat = 15, colorSelected: @escaping (UIColor) -> ()) {
        super.init(frame: frame, knobInsets: knobInset, allowedAngleRange:(-.pi/2.0)...(.pi/2.0))
        self.hue = color.hsv.hue
        self.knobRadius = knobInset
        self.knobInsets = 0
        updateBackground()
        self.brightness = color.hsv.brightness
        self.knobRotated = { [unowned self] angle in
            let selectedColor = self.color(forAngle: angle)
            self.brightness = selectedColor.hsv.brightness
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
        let brightness = 1 - color.hsv.brightness
        let angle = (0...1).remap(brightness, in: allowedAngleRange)
        return angle.normalizedAngle()
    }

    private func color(forAngle angle:CGFloat) -> UIColor {
        let recalculatedAngle = (angle > allowedAngleRange.upperBound) ? angle - 2 * .pi : angle
        let brightness = 1.0 - allowedAngleRange.remap(recalculatedAngle , in: 0...1)
        return UIColor(hue: self.hue, saturation: 1.0, brightness: brightness, alpha: 1)
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


