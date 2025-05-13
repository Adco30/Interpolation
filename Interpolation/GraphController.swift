/*
Main controller managing the graph data model, coordinate system calculations, 
and algorithm selection. Handles interpolation, integration, boundary updates, 
and coordinate grid generation using Accelerate framework.
*/

import SwiftUI
import Combine

class GraphController: ObservableObject {
    @Published var graphState: GraphViewState = GraphViewState()
    @Published var selectedAlgorithm: CalculationAlgorithm = .linear {
        didSet {
            recomputeInterpolation()
        }
    }
    @Published var showCurve: Bool = false
    
    private var canvasSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()
    private let interpolationService: MathProcessor
    private let integrationService: AreaCalculator
    private let gridService: CoordinateGridManager
    
    let gridSpacing: CGFloat = 50
    
    init(interpolationService: MathProcessor = PointInterpolator(),
         integrationService: AreaCalculator = NumericIntegrator(),
         gridService: CoordinateGridManager = GridTickGenerator()) {
        self.interpolationService = interpolationService
        self.integrationService = integrationService
        self.gridService = gridService
        
        setupBindings()
    }
    
    private func setupBindings() {
        $selectedAlgorithm
            .sink { [weak self] _ in
                self?.recomputeInterpolation()
            }
            .store(in: &cancellables)
    }
    
    func setupWithCanvasSize(_ size: CGSize) {
        guard canvasSize != size else { return }
        
        canvasSize = size
        
        let initialPoints = interpolationService.generateRandomPoints(
            count: Int(size.width / 40),
            size: size
        )
        
        graphState.graphData.pointSet = initialPoints
        graphState.graphData.leftBoundary = size.width * 0.25
        graphState.graphData.rightBoundary = size.width * 0.75
        
        recomputeInterpolation()
    }
    
    func resetPoints() {
        graphState.graphData.pointSet = interpolationService.generateRandomPoints(
            count: Int(canvasSize.width / 40),
            size: canvasSize
        )
        recomputeInterpolation()
    }
    
    func updateLeftBoundary(_ newValue: CGFloat) {
        var mutableData = graphState.graphData
        mutableData.leftBoundary = min(newValue, mutableData.rightBoundary)
        graphState.graphData = mutableData
        updateArea()
    }
    
    func updateRightBoundary(_ newValue: CGFloat) {
        var mutableData = graphState.graphData
        mutableData.rightBoundary = max(newValue, mutableData.leftBoundary)
        graphState.graphData = mutableData
        updateArea()
    }
    
    func updateArea() {
        graphState.graphData.area = integrationService.calculateArea(
            points: graphState.graphData.interpolatedPoints,
            left: graphState.graphData.leftBoundary,
            right: graphState.graphData.rightBoundary
        )
    }
    
    func generateXTicks(width: CGFloat) -> [CGFloat] {
        return gridService.generateTicks(maxValue: width, spacing: gridSpacing)
    }
    
    func generateYTicks(height: CGFloat) -> [CGFloat] {
        return gridService.generateTicks(maxValue: height, spacing: gridSpacing)
    }
    
    private func recomputeInterpolation() {
        var mutableData = graphState.graphData
        
        mutableData.interpolatedPoints = interpolationService.interpolatePoints(
            points: mutableData.pointSet,
            algorithm: selectedAlgorithm,
            steps: Int(canvasSize.width / 5)
        )
        
        mutableData.curvePath = interpolationService.createPathFromPoints(mutableData.interpolatedPoints)
        
        mutableData.area = integrationService.calculateArea(
            points: mutableData.interpolatedPoints,
            left: mutableData.leftBoundary,
            right: mutableData.rightBoundary
        )
        graphState.graphData = mutableData
    }
}

struct GraphViewState {
    var graphData = GraphDataModel()
}