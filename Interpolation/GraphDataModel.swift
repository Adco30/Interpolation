/*
Data model for graph visualization containing point sets, boundary positions, 
calculated area, and curve path. Supports boundary updates and includes 
algorithm selection enumeration.
*/

import SwiftUI

struct GraphDataModel {
    var pointSet: [CGPoint] = []
    var interpolatedPoints: [CGPoint] = []
    var leftBoundary: CGFloat = 0
    var rightBoundary: CGFloat = 0
    var area: CGFloat = 0
    var curvePath: Path = Path()
    
    mutating func updateBoundaries(left: CGFloat, right: CGFloat) {
        leftBoundary = left
        rightBoundary = right
    }
}

enum CalculationAlgorithm {
    case linear
    case quadratic
}