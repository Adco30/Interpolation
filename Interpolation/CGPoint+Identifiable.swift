/*
Extension for CGPoint to conform to Identifiable protocol, enabling its use
in SwiftUI ForEach constructs by providing unique string identifier based
on coordinate values.
*/

import CoreGraphics

extension CGPoint: Identifiable {
    public var id: String {
        "\(x)_\(y)"
    }
}