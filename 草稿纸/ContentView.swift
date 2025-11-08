import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var selectedColor: Color = .black
    @State private var selectedTool: DrawingTool = .pen
    @State private var canvasView = PKCanvasView()
    @State private var showShapes = false
    @State private var selectedShape: ShapeType = .rectangle
    @State private var showCustomColorPicker = false
    @State private var brushWidth: Double = 3.0
    @State private var customColor = Color.black
    
    let colors: [Color] = [.black, .blue, .red, .green, .yellow, .purple, .orange, .pink]
    let tools: [DrawingTool] = [.pen, .pencil, .marker, .eraser]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                // 颜色选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // 预设颜色
                        ForEach(colors, id: \.self) { color in
                            ColorCircle(color: color, isSelected: selectedColor == color) {
                                selectedColor = color
                                updateToolSettings()
                            }
                        }
                        
                        // 自定义颜色按钮
                        Button(action: {
                            showCustomColorPicker.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [.red, .green, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "paintpalette")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                /* 画笔粗细显示
                VStack(spacing: 2) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: CGFloat(brushWidth), height: CGFloat(brushWidth))
                    Text("\(Int(brushWidth))px")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }*/
                
                /* 形状按钮
                Button(action: {
                    showShapes.toggle()
                }) {
                    Image(systemName: "square.on.square")
                        .font(.title2)
                        .foregroundColor(.primary)
                }*/
                
                // 清除按钮
                Button(action: {
                    canvasView.drawing = PKDrawing()
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemBackground).shadow(radius: 2))
            
            // 绘图工具选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tools, id: \.self) { tool in
                        ToolButton(tool: tool, isSelected: selectedTool == tool) {
                            selectedTool = tool
                            updateDefaultWidthForTool()
                            updateToolSettings()
                        }
                    }
                    
                    // 画笔粗细调节器
                    BrushWidthSlider(brushWidth: $brushWidth) {
                        updateToolSettings()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // 画布区域
            ZStack {
                // 无限画布
                CanvasView(canvasView: $canvasView, tool: $selectedTool, color: $selectedColor, brushWidth: brushWidth)
                    .edgesIgnoringSafeArea(.all)
                
                // 形状叠加层
                if showShapes {
                    ShapeOverlayView(selectedShape: $selectedShape, selectedColor: $selectedColor)
                }
                
                // 自定义颜色选择器
                if showCustomColorPicker {
                    CustomColorPicker(
                        selectedColor: $selectedColor,
                        customColor: $customColor,
                        isShowing: $showCustomColorPicker
                    ) {
                        updateToolSettings()
                    }
                }
            }
        }
    }
    
    private func updateToolSettings() {
        // 这个方法现在在CanvasView内部处理
    }
    
    private func updateDefaultWidthForTool() {
        switch selectedTool {
        case .pen:
            brushWidth = 3.0
        case .pencil:
            brushWidth = 2.0
        case .marker:
            brushWidth = 10.0
        case .eraser:
            brushWidth = 20.0
        }
    }
}

// 颜色圆圈组件
struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                )
        }
    }
     
}

// 画笔粗细滑动条组件
struct BrushWidthSlider: View {
    @Binding var brushWidth: Double
    let onWidthChange: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            /*Image(systemName: "circle.fill")
                .font(.system(size: CGFloat(brushWidth / 2)))
                .foregroundColor(.primary)*/
            
            Text("粗细")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Slider(value: $brushWidth, in: 1...50, step: 1) { _ in
                onWidthChange()
            }
            .frame(width: 120)
        }
        .padding(.horizontal, 8)
    }
}

// 自定义颜色选择器
struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    @Binding var customColor: Color
    @Binding var isShowing: Bool
    let onColorSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("自定义颜色")
                .font(.headline)
            
            // 颜色选择器
            ColorPicker("选择颜色", selection: $customColor)
                .scaleEffect(x:0.9, y:1)
            
            // 预览
            
            
            HStack(spacing: 20) {
                // 取消按钮
                Button("取消") {
                    isShowing = false
                }
                .foregroundColor(.red)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // 应用按钮
                Button("应用") {
                    selectedColor = customColor
                    onColorSelected()
                    isShowing = false
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

// 更新 CanvasView 以支持自定义粗细
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var tool: DrawingTool
    @Binding var color: Color
    let brushWidth: Double
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        updateTool(uiView: canvasView)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateTool(uiView: uiView)
    }
    
    private func updateTool(uiView: PKCanvasView) {
        switch tool {
        case .pen:
            uiView.tool = PKInkingTool(.pen, color: UIColor(color), width: CGFloat(brushWidth))
        case .pencil:
            uiView.tool = PKInkingTool(.pencil, color: UIColor(color), width: CGFloat(brushWidth))
        case .marker:
            uiView.tool = PKInkingTool(.marker, color: UIColor(color), width: CGFloat(brushWidth))
        case .eraser:
            uiView.tool = PKEraserTool(.vector)
        }
    }
}

// 绘图工具枚举
enum DrawingTool {
    case pen, pencil, marker, eraser
    
    var iconName: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
    
    var name: String {
        switch self {
        case .pen: return "钢笔"
        case .pencil: return "铅笔"
        case .marker: return "马克笔"
        case .eraser: return "橡皮"
        }
    }
}

// 形状类型枚举
enum ShapeType: String, CaseIterable {
    case rectangle = "矩形"
    case circle = "圆形"
    //case line = "直线"
    case triangle = "三角形"
    case star = "星星"
    
    var iconName: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        //case .line: return "line.diagonal"
        case .triangle: return "triangle"
        case .star: return "star"
        }
    }
}

// 工具按钮组件
struct ToolButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: tool.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .primary)
                Text(tool.name)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// 形状叠加视图
struct ShapeOverlayView: View {
    @Binding var selectedShape: ShapeType
    @Binding var selectedColor: Color
    @State private var shapes: [DrawableShape] = []
    @State private var startPoint: CGPoint?
    @State private var currentEndPoint: CGPoint?
    
    var body: some View {
        ZStack {
            // 手势区域
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if startPoint == nil {
                                startPoint = value.startLocation
                            }
                            currentEndPoint = value.location
                        }
                        .onEnded { value in
                            if let start = startPoint {
                                let shape = DrawableShape(
                                    type: selectedShape,
                                    startPoint: start,
                                    endPoint: value.location,
                                    color: selectedColor
                                )
                                shapes.append(shape)
                            }
                            startPoint = nil
                            currentEndPoint = nil
                        }
                )
            
            // 绘制已完成的形状
            ForEach(shapes) { shape in
                shape.path
                    .fill(shape.color)
                    .opacity(0.7)
            }
            
            // 绘制当前正在拖拽的形状
            if let start = startPoint, let end = currentEndPoint {
                DrawableShape(
                    type: selectedShape,
                    startPoint: start,
                    endPoint: end,
                    color: selectedColor
                ).path
                    .fill(selectedColor)
                    .opacity(0.5)
            }
            
            // 形状选择器
            VStack {
                Spacer()
                HStack {
                    ForEach(ShapeType.allCases, id: \.self) { shape in
                        Button(action: {
                            selectedShape = shape
                        }) {
                            VStack {
                                Image(systemName: shape.iconName)
                                    .font(.title3)
                                    .foregroundColor(selectedShape == shape ? .blue : .primary)
                                Text(shape.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(selectedShape == shape ? .blue : .primary)
                            }
                            .padding(8)
                            .background(selectedShape == shape ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
        }
    }
}

// 可绘制形状结构体
struct DrawableShape: Identifiable {
    let id = UUID()
    let type: ShapeType
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: Color
    
    var path: Path {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        
        switch type {
        case .rectangle:
            return Path(rect)
        case .circle:
            return Path(ellipseIn: rect)
        /*case .line:
            return Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }*/
        case .triangle:
            return Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.closeSubpath()
            }
        case .star:
            return createStarPath(in: rect)
        }
    }
    
    private func createStarPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 5
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius / 2
        
        for i in 0..<points * 2 {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = .pi * Double(i) / Double(points)
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// 应用主入口
