import UIKit

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format: "#%06x", rgb)
    }
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xff0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00ff00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

