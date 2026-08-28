import SwiftUI
import shared

@main
struct iOSApp: App {
    init() {
        KoinHelper.companion.doInitKoinIos()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
