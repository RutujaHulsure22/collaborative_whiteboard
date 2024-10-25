import UIKit

struct DrawingAction: Codable {
    var tool: String  // pen, eraser, etc.
    var color: String // Hex color
    var startPoint: CGPoint
    var endPoint: CGPoint
    var lineWidth: CGFloat
}

