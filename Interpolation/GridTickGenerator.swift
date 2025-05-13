/*
Grid tick generation service using Accelerate framework for coordinate system
rendering. Calculates evenly spaced tick positions for axes with configurable
spacing using vectorized operations.
*/

import CoreGraphics
import Accelerate

protocol CoordinateGridManager {
    func generateTicks(maxValue: CGFloat, spacing: CGFloat) -> [CGFloat]
}

class GridTickGenerator: CoordinateGridManager {
    func generateTicks(maxValue: CGFloat, spacing: CGFloat) -> [CGFloat] {
        guard maxValue > 0, spacing > 0 else { return [] }
        
        let count = Int(maxValue / spacing) + 1
        guard count > 0 else { return [] }
        
        var ticks = [Float](repeating: 0, count: count)
        var start: Float = 0
        var increment: Float = Float(spacing)
        vDSP_vramp(&start, &increment, &ticks, 1, vDSP_Length(count))
        
        return ticks.map { CGFloat($0) }.filter { $0 <= maxValue }
    }
}