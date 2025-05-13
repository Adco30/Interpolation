/*
Point interpolation service using Accelerate framework for high-performance
calculations. Provides linear and quadratic interpolation algorithms with
SIMD optimizations for smooth curve generation.
*/

import CoreGraphics
import SwiftUI
import Accelerate
import simd

protocol MathProcessor {
    func generateRandomPoints(count: Int, size: CGSize) -> [CGPoint]
    func interpolatePoints(points: [CGPoint], algorithm: CalculationAlgorithm, steps: Int) -> [CGPoint]
    func createPathFromPoints(_ points: [CGPoint]) -> Path
}

class PointInterpolator: MathProcessor {
    func generateRandomPoints(count: Int, size: CGSize) -> [CGPoint] {
        let spacing = max(size.width / CGFloat(count - 1), 1)
        let range = (0.1 * size.height)..<(0.9 * size.height)
        
        var xCoordinates = [Float](repeating: 0, count: count)
        var startValue: Float = 0
        var increment: Float = Float(spacing)
        vDSP_vramp(&startValue, &increment, &xCoordinates, 1, vDSP_Length(count))
        
        var yCoordinates = [Float](repeating: 0, count: count)
        for i in 0..<count {
            yCoordinates[i] = Float.random(in: Float(range.lowerBound)...Float(range.upperBound))
        }
        
        return zip(xCoordinates, yCoordinates).map { CGPoint(x: CGFloat($0), y: CGFloat($1)) }
    }
    
    func interpolatePoints(points: [CGPoint], algorithm: CalculationAlgorithm, steps: Int) -> [CGPoint] {
        guard points.count > 1, steps > 0 else { return [] }
        
        let vals = points.map { Float($0.y) }
        let denom = Float(steps) / Float(points.count - 1)
        
        func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
            let t = simd_clamp((x - edge0) / (edge1 - edge0), 0, 1)
            return t * t * (3 - 2 * t)
        }
        
        func fract(_ x: Float) -> Float {
            return x - floor(x)
        }
        
        var controlX = [Float](repeating: 0, count: steps)
        var startValue: Float = 0
        var increment: Float = 1.0 / denom
        vDSP_vramp(&startValue, &increment, &controlX, 1, vDSP_Length(steps))
        
        let control = controlX.map { x in
            floor(x) + smoothstep(0, 1, fract(x))
        }
        
        var result = [Float](repeating: 0, count: steps)
        
        switch algorithm {
        case .linear:
            for i in 0..<steps {
                let x = control[i]
                let index = Int(floor(x))
                
                if index >= vals.count - 1 {
                    result[i] = vals[vals.count - 1]
                    continue
                }
                
                let fraction = x - Float(index)
                let oneMinusFraction = 1 - fraction
                
                let v = simd_float2(vals[index], vals[index + 1])
                let weights = simd_float2(oneMinusFraction, fraction)
                result[i] = simd_dot(v, weights)
            }
            
        case .quadratic:
            for i in 0..<steps {
                let x = control[i]
                let index = Int(floor(x))
                
                if index >= vals.count - 2 {
                    if index >= vals.count - 1 {
                        result[i] = vals[vals.count - 1]
                    } else {
                        let fraction = x - Float(index)
                        let v = simd_float2(vals[index], vals[index + 1])
                        let weights = simd_float2(1 - fraction, fraction)
                        result[i] = simd_dot(v, weights)
                    }
                    continue
                }
                
                let fraction = x - Float(index)
                let coeffs = simd_float3(
                    (vals[index + 2] - 2 * vals[index + 1] + vals[index]) / 2,
                    vals[index + 1] - vals[index] - (vals[index + 2] - 2 * vals[index + 1] + vals[index]) / 2,
                    vals[index]
                )
                
                let powers = simd_float3(fraction * fraction, fraction, 1)
                let poly = simd_float3(coeffs.x, coeffs.y, coeffs.z)
                result[i] = simd_dot(poly, powers)
            }
        }
        
        let minX = points.first!.x
        let maxX = points.last!.x
        let stepX = (maxX - minX) / CGFloat(steps - 1)
        
        var xCoordinates = [Float](repeating: 0, count: steps)
        var startX = Float(minX)
        var incrementX = Float(stepX)
        vDSP_vramp(&startX, &incrementX, &xCoordinates, 1, vDSP_Length(steps))
        
        return zip(xCoordinates, result).map { CGPoint(x: CGFloat($0), y: CGFloat($1)) }
    }
    
    func createPathFromPoints(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }
        
        path.move(to: points.first!)
        points.dropFirst().forEach { path.addLine(to: $0) }
        
        return path
    }
}