import ComposableArchitecture
import SwiftUI

@main
struct VerticalApp: App {
    // SINGLE SOURCE OF TRUTH
    // We initialise the store once at the root of the app.
    static let store = Store(initialState: AppReducer.State()) {
        AppReducer()
        // In debug builds, we can print all state changes to the console
        ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: VerticalApp.store)
        }
    }
}
