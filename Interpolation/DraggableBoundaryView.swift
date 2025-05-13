/*
Interactive boundary line view with draggable handle for adjusting integration limits.
Renders a dashed line with circular drag handle for precise boundary positioning.
*/

import SwiftUI

struct DraggableBoundaryView: View {
    let position: CGFloat
    let height: CGFloat
    let minX: CGFloat
    let maxX: CGFloat
    let onPositionChanged: (CGFloat) -> Void
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: position, y: 0))
                path.addLine(to: CGPoint(x: position, y: height))
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 1, dash: [5]))
            
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.gray)
                .position(x: position, y: height / 2)
        }
        .gesture(
            DragGesture().onChanged { value in
                let newX = min(max(minX, value.location.x), maxX)
                onPositionChanged(newX)
            }
        )
    }
}