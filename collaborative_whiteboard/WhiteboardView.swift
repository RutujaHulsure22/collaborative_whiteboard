import UIKit

class WhiteboardView: UIView {
    
    var shapes: [(start: CGPoint, end: CGPoint, tool: DrawingTool)] = []
    var selectedTool: DrawingTool = .pen(color: .black, width: 5.0)
    var lastPoint: CGPoint!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        
        if case .pen(let color, let width) = selectedTool {
            shapes.append((start: lastPoint, end: currentPoint, tool: .pen(color: color, width: width)))
        } else if case .eraser(let width) = selectedTool {
            shapes.append((start: lastPoint, end: currentPoint, tool: .eraser(width: width)))
        }
        if case .circle(let color, let width) = selectedTool {
                if !shapes.isEmpty, let lastShape = shapes.last, case .circle = lastShape.tool {
                    shapes.removeLast()
                }
                
                let _ = hypot(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y)
                
                shapes.append((start: lastPoint, end: currentPoint, tool: .circle(color: color, width: width)))
            }

        lastPoint = currentPoint
        setNeedsDisplay()
    }

   
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)

        switch selectedTool {
        case .line(let color, let width):
            shapes.append((start: lastPoint, end: currentPoint, tool: .line(color: color, width: width)))

        case .rectangle(let color, let width):
            shapes.append((start: lastPoint, end: currentPoint, tool: .rectangle(color: color, width: width)))

        case .circle(let color, let width):
            _ = hypot(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y)
            shapes.append((start: lastPoint, end: currentPoint, tool: .circle(color: color, width: width)))

        default:
            break
        }

        setNeedsDisplay()
    }



    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineCap(.round)

        for shape in shapes {
            switch shape.tool {
            case .pen(let color, let width):
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(width)
                context.move(to: shape.start)
                context.addLine(to: shape.end)
                context.strokePath()
            case .line(let color, let width):
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(width)
                context.move(to: shape.start)
                context.addLine(to: shape.end)
                context.strokePath()
            case .rectangle(let color, let width):
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(width)
                let rectangle = CGRect(x: min(shape.start.x, shape.end.x), y: min(shape.start.y, shape.end.y),
                                       width: abs(shape.end.x - shape.start.x), height: abs(shape.end.y - shape.start.y))
                context.addRect(rectangle)
                context.strokePath()
            case .circle(let color, let width):
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(width)
                let radius = hypot(shape.end.x - shape.start.x, shape.end.y - shape.start.y)
                context.addEllipse(in: CGRect(x: shape.start.x - radius, y: shape.start.y - radius,
                                              width: 2 * radius, height: 2 * radius))
                context.strokePath()

            case .eraser(let width):
                context.setStrokeColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
                context.setLineWidth(width)
                context.move(to: shape.start)
                context.addLine(to: shape.end)
                context.strokePath()
            }
        }
    }
    
    func clear() {
        shapes.removeAll()
        setNeedsDisplay()
    }
}
