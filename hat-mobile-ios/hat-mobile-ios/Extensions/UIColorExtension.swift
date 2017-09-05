/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Extension

extension UIColor {
    
    // MARK: - Staticly defined colors
    
    // swiftlint:disable object_literal
    static let appBase: UIColor = .primaryDarkColor
    static let primaryColor: UIColor = UIColor.fromRGB(0x203551)
    static let primaryDarkColor: UIColor = UIColor.fromRGB(0x131F34)
    static let secondaryColor: UIColor = UIColor.fromRGB(0x132845)
    static let tertaryColor: UIColor = UIColor.fromRGB(0x00304A)
    static let accentColor: UIColor = UIColor.fromRGB(0x7ADFC7)
    static let accentDarkColor: UIColor = UIColor.fromRGB(0x81DEC7)
    
    static let toolbarColor: UIColor = .primaryDarkColor

    static let rumpelDarkGray: UIColor = UIColor(red: 29 / 255, green: 49 / 255, blue: 53 / 255, alpha: 1)
    static let rumpelVeryLightGray: UIColor = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 1)
    
    static let onSwitchTintColor: UIColor = UIColor(red: 144 / 255, green: 202 / 255, blue: 119 / 255, alpha: 1)
    // swiftlint:enable object_literal
    
    // MARK: - Methods
    
    /**
     Returns an UIColor object from a RGB value
     
     - parameter rgbValue: The rgb value as UInt
     
     - returns: A UIColor based on the rgbValue
     */
    public class func fromRGB(_ rgbValue: UInt) -> UIColor {
        
        return self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
