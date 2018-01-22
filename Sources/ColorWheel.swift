//
//  ColorWheel.swift
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

public class ColorWheel: UIControl {

    public var color: HSV!

    public init(frame: CGRect, color: UIColor, colorSelected: @escaping (UIColor) -> ()) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.color = color.hsv
        var huePicker:HuePicker?
        var saturationPicker:SaturationPicker?
        var brightnessPicker:BrightnessPicker?

        huePicker = HuePicker(frame: frame, color: color.hsv, knobInset: 20) { [unowned self] (newHue) in
            self.color.hue = newHue
            saturationPicker?.hue = newHue
            brightnessPicker?.hue = newHue
            self.sendActions(for: .valueChanged)
            colorSelected(UIColor(hsv: self.color))
        }
        
        saturationPicker = SaturationPicker(frame: frame, color: color, knobInset: 10) { [unowned self] (newColor) in
            self.color.saturation = newColor.hsv.saturation
            huePicker?.colorHSV.saturation = self.color.saturation
            self.sendActions(for: .valueChanged)
            colorSelected(UIColor(hsv: self.color))
        }
        
        brightnessPicker = BrightnessPicker(frame: frame, color: color, knobInset: 10) { [unowned self] (newColor) in
            self.color.brightness = newColor.hsv.brightness
            huePicker?.colorHSV.brightness = self.color.brightness
            self.sendActions(for: .valueChanged)
            colorSelected(UIColor(hsv: self.color))
        }
        
        self.addSubview(saturationPicker!)
        self.addSubview(brightnessPicker!)
        self.addSubview(huePicker!)

        NSLayoutConstraint.activate([
            huePicker!.widthAnchor.constraint(equalTo: huePicker!.heightAnchor),
            huePicker!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            huePicker!.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            huePicker!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            huePicker!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            ])

        NSLayoutConstraint.activate([
            saturationPicker!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            saturationPicker!.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            saturationPicker!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            saturationPicker!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            ])
        
        NSLayoutConstraint.activate([
            brightnessPicker!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            brightnessPicker!.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            brightnessPicker!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            brightnessPicker!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
