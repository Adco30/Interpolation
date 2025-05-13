/*
Main visualization view that displays the interpolated curve, control points, 
integration boundaries, and area calculation. Provides UI controls for algorithm 
selection and point management.
*/

import SwiftUI

struct DataVisualizationView: View {
    @StateObject private var viewController = GraphController()
    
    var body: some View {
        VStack {
            HStack {
                Button("Reset points") {
                    viewController.resetPoints()
                }
                .padding()
                .border(Color.blue)
                
                Spacer()
                
                Toggle("Draw curve", isOn: $viewController.showCurve)
                
                Spacer()
                
                Picker("Algorithm", selection: $viewController.selectedAlgorithm) {
                    Text("linear").tag(CalculationAlgorithm.linear)
                    Text("quadratic").tag(CalculationAlgorithm.quadratic)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Text("Area under the curve: \(String(format: "%.2f", viewController.graphState.graphData.area))")
            
            GeometryReader { geo in
                ZStack {
                    let xTicks = viewController.generateXTicks(width: geo.size.width)
                    let yTicks = viewController.generateYTicks(height: geo.size.height)
                    
                    GridRenderingView(
                        xTicks: xTicks,
                        yTicks: yTicks,
                        canvasSize: geo.size,
                        gridSpacing: viewController.gridSpacing
                    )
                    
                    renderAreaUnderCurve(height: geo.size.height)
                    renderCurveVisualization()
                    renderControlPoints()
                    renderBoundaryLines(height: geo.size.height, maxWidth: geo.size.width)
                }
                .onAppear {
                    viewController.setupWithCanvasSize(geo.size)
                }
            }
            .padding()
        }
        .padding()
    }
    
    private func renderAreaUnderCurve(height: CGFloat) -> some View {
        Path { path in
            let segment = viewController.graphState.graphData.interpolatedPoints.filter {
                $0.x >= viewController.graphState.graphData.leftBoundary && $0.x <= viewController.graphState.graphData.rightBoundary
            }
            
            guard segment.count > 1 else { return }
            
            path.move(to: CGPoint(x: viewController.graphState.graphData.leftBoundary, y: height))
            segment.forEach { path.addLine(to: $0) }
            path.addLine(to: CGPoint(x: viewController.graphState.graphData.rightBoundary, y: height))
            path.closeSubpath()
        }
        .fill(Color.blue.opacity(0.2))
    }
    
    private func renderCurveVisualization() -> some View {
        Group {
            if viewController.showCurve {
                viewController.graphState.graphData.curvePath.stroke(Color.blue, lineWidth: 2)
            } else {
                ForEach(viewController.graphState.graphData.interpolatedPoints, id: \.id) { point in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 2, height: 2)
                        .position(point)
                }
            }
        }
    }
    
    private func renderControlPoints() -> some View {
        ForEach(viewController.graphState.graphData.pointSet, id: \.id) { point in
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .position(point)
        }
    }
    
    private func renderBoundaryLines(height: CGFloat, maxWidth: CGFloat) -> some View {
        ZStack {
            DraggableBoundaryView(
                position: viewController.graphState.graphData.leftBoundary,
                height: height,
                minX: 0,
                maxX: viewController.graphState.graphData.rightBoundary,
                onPositionChanged: { newValue in
                    viewController.updateLeftBoundary(newValue)
                }
            )
            
            DraggableBoundaryView(
                position: viewController.graphState.graphData.rightBoundary,
                height: height,
                minX: viewController.graphState.graphData.leftBoundary,
                maxX: maxWidth,
                onPositionChanged: { newValue in
                    viewController.updateRightBoundary(newValue)
                }
            )
        }
    }
}