import UIKit

enum DrawingTool {
    case pen(color: UIColor, width: CGFloat)
    case eraser(width: CGFloat)
    case line(color: UIColor, width: CGFloat)
    case rectangle(color: UIColor, width: CGFloat)
    case circle(color: UIColor, width: CGFloat)
}

struct Line: Codable {
    let start: CGPoint
    let end: CGPoint
    private var colorHex: String
    let width: CGFloat

    var color: UIColor {
        get {
            return UIColor(hex: colorHex)
        }
        set {
            colorHex = newValue.toHexString()        
        }
    }
    
    init(start: CGPoint, end: CGPoint, color: UIColor, width: CGFloat) {
        self.start = start
        self.end = end
        self.width = width
        self.colorHex = color.toHexString()
    }
}


