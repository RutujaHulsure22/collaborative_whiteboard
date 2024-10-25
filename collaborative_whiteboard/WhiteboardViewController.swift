import UIKit
import Starscream

class WhiteboardViewController: UIViewController, WebSocketDelegate {

    @IBOutlet weak var whiteboardView: WhiteboardView!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var penButton: UIButton!
    
    var selectedColor: UIColor = .black
    var socket: WebSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: "wss://echo.websocket.org")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        setUpToolView()
        setUpUI()
    }
    
    func setupColorPickerButton(){
        colorPickerButton.setImage(UIImage(systemName: "eyedropper"), for: .normal)
        colorPickerButton.backgroundColor = UIColor.white
        colorPickerButton.layer.borderColor = UIColor.black.cgColor
        colorPickerButton.layer.cornerRadius = 0.5 * colorPickerButton.bounds.size.width
        colorPickerButton.clipsToBounds = true
    }
    
    func setUpUI(){
        let toolsArray = [eraserButton, lineButton, circleButton, rectangleButton, penButton]
        let tags: [Int] = [1, 2, 3, 4, 5]
        let images = [UIImage(systemName: "eraser.fill"), UIImage(systemName: "circle"), UIImage(systemName: "rectangle"), UIImage(systemName: "line.diagonal"),
                      UIImage(systemName: "pencil")]
        
        for (index, button) in toolsArray.enumerated(){
            button?.backgroundColor = UIColor.white
            button?.layer.borderColor = UIColor.black.cgColor
            button?.layer.cornerRadius = 0.5 * colorPickerButton.bounds.size.width
            button?.clipsToBounds = true
            button?.tag = tags[index]
            button?.setImage(images[index], for: .normal)
        }
    }
    func setUpToolView(){
        toolView.layer.cornerRadius = 8.0
        toolView.clipsToBounds = true
        toolView.backgroundColor = UIColor.lightGray
        setupColorPickerButton()
    }
        
    @IBAction func pickColor(_ sender: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.selectedColor = selectedColor
        present(colorPicker, animated: true, completion: nil)
    }
        
    @IBAction func selectColor(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            whiteboardView.selectedTool = .pen(color: color, width: 5.0)
            self.selectedColor = color
        }
    }

    @IBAction func selectShape(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            whiteboardView.selectedTool = .eraser(width: 10.0)
        case 2:
            whiteboardView.selectedTool = .line(color: selectedColor, width: 5.0)
        case 3:
            whiteboardView.selectedTool = .circle(color: selectedColor, width: 5.0)
        case 4:
            whiteboardView.selectedTool = .rectangle(color: selectedColor, width: 5.0)
        case 5:
            whiteboardView.selectedTool = .pen(color: selectedColor, width: 5.0)
        default:
            break
        }
    }

    @IBAction func clearBoard(_ sender: UIButton) {
        whiteboardView.clear()
    }

    func sendDrawingAction(_ drawingAction: DrawingAction) {
        do {
            let jsonData = try JSONEncoder().encode(drawingAction)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket?.write(string: jsonString)
            }
        } catch {
            print("Failed to encode drawing action: \(error)")
        }
    }

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .text(let text):
            print("Received drawing data: \(text)")
            if let data = text.data(using: .utf8) {
                do {
                    let receivedAction = try JSONDecoder().decode(DrawingAction.self, from: data)
                    
                    DispatchQueue.main.async {
                        // Append to shapes and draw it
                        let color = UIColor(hex: receivedAction.color)
                        let tool: DrawingTool = .pen(color: color, width: receivedAction.lineWidth)
                        
                        self.whiteboardView.shapes.append((
                            start: receivedAction.startPoint,
                            end: receivedAction.endPoint,
                            tool: tool
                        ))
                        self.whiteboardView.setNeedsDisplay()
                    }
                } catch {
                    print("Failed to decode drawing action: \(error)")
                }
            }
        default:
            break
        }
    }
    
    func handleIncomingMessage(_ message: String) {
        if let data = message.data(using: .utf8) {
            if let drawingAction = try? JSONDecoder().decode(DrawingAction.self, from: data) {
                DispatchQueue.main.async {
                    // Append to shapes
                    let color = UIColor(hex: drawingAction.color)
                    let tool: DrawingTool = .pen(color: color, width: drawingAction.lineWidth)
                    
                    self.whiteboardView.shapes.append((
                        start: drawingAction.startPoint,
                        end: drawingAction.endPoint,
                        tool: tool
                    ))
                    self.whiteboardView.setNeedsDisplay()
                }
            }
        }
    }
}

extension WhiteboardViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        whiteboardView.selectedTool = .pen(color: selectedColor, width: 5.0)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("Selected color: \(selectedColor)")
    }
}
