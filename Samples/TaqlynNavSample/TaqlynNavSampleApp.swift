import SwiftUI
import TaqlynNavSwiftUI

/// Proof harness — depends on TaqlynNavSwiftUI only (no SdkCore / pasteboard / HTTP).
@main
struct TaqlynNavSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
