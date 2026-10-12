import Foundation

/// Minimal href carrier so nav-swiftui does not depend on TaqlynSDK types.
public struct ResolvedHref: Sendable, Equatable {
    public var href: String
    public var linkId: String?
    public var pendingExpand: Bool

    public init(href: String, linkId: String? = nil, pendingExpand: Bool = false) {
        self.href = href
        self.linkId = linkId
        self.pendingExpand = pendingExpand
    }
}

/// Gap 1 — expand a warm short URL before navigation.
///
/// Inject `SdkCore.resolveIncomingUrl`. Returns `fallbackPath` on failure.
public func expandIncomingRoute(
    url: String,
    resolveIncomingUrl: (String) async -> ResolvedHref?,
    fallbackPath: String = "/"
) async -> String {
    if let resolved = await resolveIncomingUrl(url), !resolved.href.isEmpty {
        return resolved.href
    }
    return fallbackPath
}
