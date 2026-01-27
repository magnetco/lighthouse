import SwiftUI

@main
struct LighthouseApp: App {
    @StateObject private var viewModel = PortViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
        } label: {
            Image(systemName: "light.beacon.max.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
