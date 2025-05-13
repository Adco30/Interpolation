# Curve Interpolation

This application provides interactive visualization of mathematical curve interpolation techniques. Users can view, manipulate, and analyze curves using different interpolation algorithms, calculate the area under specified regions, and interact with a dynamic coordinate system.



https://github.com/user-attachments/assets/6ae47909-54a8-48a1-a46b-5267b67b6ca3


## Core Functionality

- Curve interpolation with linear and quadratic methods
- Visual representation of mathematical functions
- Definite integration for area calculation
- Interactive boundary selection
- Grid-based coordinate system

## Architecture

### MathCurveManager
Central state management for curve data and algorithm selection.

### CurveDisplayUI
Primary view component with UI controls and visualization canvas.

### CoordinateSystem
Grid renderer with axes, tick marks, and coordinate labels.

### MathCalculationService
Mathematical operations:
- Random coordinate generation within bounds
- Linear interpolation with smoothing functions
- Quadratic polynomial interpolation

### AreaComputer
Numerical integration for area calculations between boundaries.

### MovableIndicatorLine
Draggable vertical indicators for integration boundaries.

## User Interface

- Point reset button for new random datasets
- Toggle for curve rendering modes
- Segmented control for algorithm selection
- Draggable boundary markers for area calculation

## Implementation Details

- Accelerate framework for SIMD operations
- vDSP functions for vector computations
- SwiftUI declarative interface
- Combine framework for reactive updates

## Interpolation Algorithms

### Linear Method
- Weighted average between consecutive points
- Smoothstep function for transition curves
- Linear time complexity

### Quadratic Method
- Second-degree polynomial fitting
- Three-point interpolation windows
- Boundary condition handling

## Coordinate System

- Fixed 50-pixel grid spacing
- Dynamic range based on canvas dimensions
- Labeled axes with numeric values
- High-contrast visualization

## Integration

- Trapezoidal rule implementation
- Boundary-constrained calculations
- Vector-optimized summation
- Real-time area updates
