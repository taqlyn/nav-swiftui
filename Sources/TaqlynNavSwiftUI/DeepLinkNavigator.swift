import Foundation

/// Maps a deferred / warm `DeferredLink` onto a typed SwiftUI navigation stack.
///
/// - Important: On success the path is **replaced / rebuilt** (not appended).
///   Bind `path` to `NavigationStack(path:)` so the stack matches the mapped routes.
/// - Note: Deduplicates by `linkId` until `clearConsumed()` so the same delivery
///   cannot navigate twice after ready-gate → navigate → consume.
public final class DeepLinkNavigator<Route: Hashable>: @unchecked Sendable {
    private let map: (DeferredLink) -> [Route]?
    private let lock = NSLock()
    private var lastNavigatedLinkId: String?

    /// - Parameter map: Return the full stack of routes for `link`, or `nil` / empty to skip.
    public init(map: @escaping (DeferredLink) -> [Route]?) {
        self.map = map
    }

    /// Last `linkId` that successfully navigated, if any.
    public var lastLinkId: String? {
        lock.lock()
        defer { lock.unlock() }
        return lastNavigatedLinkId
    }

    /// Rebuild `path` from the mapped routes for `link`.
    ///
    /// - Returns: `true` when the path was replaced; `false` when the mapper
    ///   returned `nil`/empty or `link.linkId` was already navigated.
    @discardableResult
    public func navigate(_ link: DeferredLink, path: inout [Route]) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if let last = lastNavigatedLinkId, last == link.linkId {
            return false
        }

        guard let routes = map(link), !routes.isEmpty else {
            return false
        }

        path = routes
        lastNavigatedLinkId = link.linkId
        return true
    }

    /// Clears the last-navigated `linkId` so a later delivery of the same id can navigate again.
    /// Call after intentional reset (e.g. logout) — not required after SdkCore.consume.
    public func clearConsumed() {
        lock.lock()
        defer { lock.unlock() }
        lastNavigatedLinkId = nil
    }
}
