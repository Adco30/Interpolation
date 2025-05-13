/*
Renders the coordinate grid system with white background, axis lines, tick marks, 
and coordinate labels. Supports customizable grid spacing and coordinate system display.
*/

import SwiftUI

struct GridRenderingView: View {
    let xTicks: [CGFloat]
    let yTicks: [CGFloat]
    let canvasSize: CGSize
    let gridSpacing: CGFloat
    
    init(xTicks: [CGFloat], yTicks: [CGFloat], canvasSize: CGSize, gridSpacing: CGFloat) {
        self.xTicks = xTicks
        self.yTicks = yTicks
        self.canvasSize = canvasSize
        self.gridSpacing = gridSpacing
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
            renderGridLines()
            renderAxes()
            renderXAxisTicks()
            renderYAxisTicks()
        }
    }
    
    private func renderGridLines() -> some View {
        Path { path in
            xTicks.forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
            }
            
            yTicks.forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
    
    private func renderAxes() -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: canvasSize.height))
            path.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height))
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: canvasSize.height))
        }
        .stroke(Color.black, lineWidth: 2)
    }
    
    private func renderXAxisTicks() -> some View {
        ForEach(xTicks, id: \.self) { x in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: x, y: canvasSize.height))
                    path.addLine(to: CGPoint(x: x, y: canvasSize.height - 5))
                }
                .stroke(Color.black, lineWidth: 1)
                
                Text("\(Int(x / gridSpacing))")
                    .font(.caption2)
                    .foregroundColor(.black)
                    .position(x: x, y: canvasSize.height + 10)
            }
        }
    }
    
    private func renderYAxisTicks() -> some View {
        ForEach(yTicks, id: \.self) { y in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: 5, y: y))
                }
                .stroke(Color.black, lineWidth: 1)
                
                Text("\(Int((canvasSize.height - y) / gridSpacing))")
                    .font(.caption2)
                    .foregroundColor(.black)
                    .position(x: -10, y: y)
            }
        }
    }
}