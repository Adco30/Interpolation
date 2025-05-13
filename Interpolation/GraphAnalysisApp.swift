/*
Entry point for the graph analysis application using SwiftUI.
Configures the main window and displays the primary visualization view.
*/

import SwiftUI

@main
struct GraphAnalysisApp: App {
    var body: some Scene {
        WindowGroup {
            DataVisualizationView()
        }
    }
}