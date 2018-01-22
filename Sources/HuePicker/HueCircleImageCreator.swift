//
//  HueCircleImageCreator.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 27.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Iris
import CoreGraphics
import CoreImage
import UIKit

class HueCircleImageCreator: CIColorImageCreator {
    
    var imageFactory: CIColorImageFactory
    
    init() throws {
        try imageFactory = CIColorImageFactory(shaderName: "ColorWheel", fromBundle: Bundle(for: HueCircleImageCreator.self))
    }
    
    func ciImage(withFrame frame: CGRect) -> CIImage? {
        return imageFactory.ciImage(withFrame: frame, andArguments: argumentsFrom(frame: frame))
    }
    
    func cgImage(withFrame frame: CGRect) -> CGImage? {
        return imageFactory.cgImage(withFrame: frame, andArguments: argumentsFrom(frame: frame))
    }
    
    private func argumentsFrom(frame: CGRect) -> [Any] {
        let radius = (frame.width / 2.0) + 1
        return [CIVector(cgPoint: frame.center), NSNumber(value: Double(radius))]
    }
}

