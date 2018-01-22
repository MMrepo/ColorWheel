//
//  SaturationHalfCircleImageCreator.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 22.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Iris
import CoreGraphics
import CoreImage
import UIKit

class SaturationHalfCircleImageCreator: CIColorImageCreator {
    public var hue: CGFloat
    
    var imageFactory: CIColorImageFactory
    private var arguments: [Any] {
        let startColor = UIColor(hue: self.hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        let endColor = UIColor(hue: self.hue, saturation: 0, brightness: 1.0, alpha: 1.0)
        
        let ciStartColor = CIColor(color: startColor)
        let ciEndColor = CIColor(color: endColor)
        return [ciStartColor, ciEndColor]
    }
    
    init() throws {
        hue = 0
        try imageFactory = CIColorImageFactory(shaderName: "GradientHalfCircle", fromBundle: Bundle(for: SaturationHalfCircleImageCreator.self))
    }
    
    func ciImage(withFrame frame: CGRect) -> CIImage? {
        return imageFactory.ciImage(withFrame: frame, andArguments: arguments + argumentsFrom(frame: frame))
    }
    
    func cgImage(withFrame frame: CGRect) -> CGImage? {
        return imageFactory.cgImage(withFrame: frame, andArguments: arguments + argumentsFrom(frame: frame))
    }
    
    private func argumentsFrom(frame: CGRect) -> [Any] {
        let radius = (frame.width / 2.0) + 1
        return [CIVector(cgPoint: frame.center), NSNumber(value: Double(radius))]
    }
}
