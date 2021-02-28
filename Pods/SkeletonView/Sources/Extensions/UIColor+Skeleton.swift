//  Copyright © 2017 SkeletonView. All rights reserved.

import UIKit

// codebeat:disable[TOO_MANY_IVARS]
extension UIColor {
    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func isLight() -> Bool {
        guard let components = cgColor.components,
              components.count >= 3 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return !(brightness < 0.5)
    }

    public var complementaryColor: UIColor {
        if #available(iOS 13, tvOS 13, *) {
            return UIColor { _ in
                self.isLight() ? self.darker : self.lighter
            }
        } else {
            return isLight() ? darker : lighter
        }
    }

    public var lighter: UIColor {
        adjust(by: 1.35)
    }

    public var darker: UIColor {
        adjust(by: 0.94)
    }

    func adjust(by percent: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * percent, alpha: a)
    }

    func makeGradient() -> [UIColor] {
        [self, complementaryColor, self]
    }
}

public extension UIColor {
    // swiftlint:disable operator_usage_whitespace
    static var greenSea = UIColor(0x16A085)
    static var turquoise = UIColor(0x1ABC9C)
    static var emerald = UIColor(0x2ECC71)
    static var peterRiver = UIColor(0x3498DB)
    static var amethyst = UIColor(0x9B59B6)
    static var wetAsphalt = UIColor(0x34495E)
    static var nephritis = UIColor(0x27AE60)
    static var belizeHole = UIColor(0x2980B9)
    static var wisteria = UIColor(0x8E44AD)
    static var midnightBlue = UIColor(0x2C3E50)
    static var sunFlower = UIColor(0xF1C40F)
    static var carrot = UIColor(0xE67E22)
    static var alizarin = UIColor(0xE74C3C)
    static var clouds = UIColor(0xECF0F1)
    static var darkClouds = UIColor(0x1C2325)
    static var concrete = UIColor(0x95A5A6)
    static var flatOrange = UIColor(0xF39C12)
    static var pumpkin = UIColor(0xD35400)
    static var pomegranate = UIColor(0xC0392B)
    static var silver = UIColor(0xBDC3C7)
    static var asbestos = UIColor(0x7F8C8D)
    // swiftlint:enable operator_usage_whitespace

    static var skeletonDefault: UIColor {
        if #available(iOS 13, tvOS 13, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .darkClouds
                default:
                    return .clouds
                }
            }
        } else {
            return .clouds
        }
    }
}

// codebeat:enable[TOO_MANY_IVARS]
