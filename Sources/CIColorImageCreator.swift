//
//  CIColorImageCreator.swift
//  ColorWheel-iOS
//
//  Created by Mateusz on 22.12.2017.
//  Copyright © 2017 Vindur. All rights reserved.
//

import Iris
import CoreGraphics
import CoreImage

protocol CIColorImageCreator {
    
    var imageFactory: CIColorImageFactory { get }
    
    func ciImage(withFrame frame:CGRect) -> CIImage?
    func cgImage(withFrame frame:CGRect) -> CGImage?
}
