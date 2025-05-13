/*
Numeric integration service using the trapezoidal rule with Accelerate framework
for efficient area calculation under curves. Filters point segments within 
specified boundaries and computes area using vectorized operations.
*/

import CoreGraphics
import Accelerate

protocol AreaCalculator {
    func calculateArea(points: [CGPoint], left: CGFloat, right: CGFloat) -> CGFloat
}

class NumericIntegrator: AreaCalculator {
    func calculateArea(points: [CGPoint], left: CGFloat, right: CGFloat) -> CGFloat {
        let segment = points.filter { $0.x >= left && $0.x <= right }
        guard segment.count > 1 else { return 0 }
        
        let ys = segment.map { Float($0.y) }
        let dx = Float((segment.last!.x - segment.first!.x) / CGFloat(segment.count - 1))
        
        let ysHead = [Float](ys.dropLast())
        let ysTail = [Float](ys.dropFirst())
        
        var sums = [Float](repeating: 0, count: ysHead.count)
        vDSP_vadd(ysHead, 1, ysTail, 1, &sums, 1, vDSP_Length(ysHead.count))
        
        var scaleFactor = dx / 2.0
        var result = [Float](repeating: 0, count: sums.count)
        vDSP_vsmul(sums, 1, &scaleFactor, &result, 1, vDSP_Length(sums.count))
        
        var totalSum: Float = 0
        vDSP_sve(result, 1, &totalSum, vDSP_Length(result.count))
        
        return CGFloat(totalSum)
    }
}