import SwiftUI

/// Thin helpers for binding a typed route array to `NavigationStack`.
///
/// Prefer keeping app state as `[Route]` and passing `$path` into
/// `NavigationStack(path:)` — that is the supported typed API for
/// `DeepLinkNavigator.navigate(_:path:)`.
public enum TaqlynNavigationStack {
    /// Documents the intended SwiftUI binding: typed path + `NavigationStack(path:)`.
    ///
    /// ```swift
    /// @State private var path: [AppRoute] = []
    /// NavigationStack(path: $path) { … }
    /// navigator.navigate(link, path: &path)
    /// ```
    public static let typedPathGuidance =
        "Bind [Route] to NavigationStack(path:) and pass &path into DeepLinkNavigator.navigate."
}
