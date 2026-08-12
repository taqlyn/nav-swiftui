import Foundation

/// Canonical resolve payload — mirrors `packages/sdk-contract` DeferredLink.
///
/// This package does **not** depend on TaqlynSDK. Copy fields from
/// `TaqlynSDK.DeferredLink` at the app boundary before calling
/// `DeepLinkNavigator.navigate`.
public struct DeferredLink: Sendable, Equatable, Hashable {
    public var url: String
    public var path: String
    public var params: [String: String]
    public var linkId: String
    public var matchType: MatchType
    public var isDeferred: Bool
    public var campaign: Campaign?

    public init(
        url: String,
        path: String,
        params: [String: String] = [:],
        linkId: String,
        matchType: MatchType,
        isDeferred: Bool,
        campaign: Campaign? = nil
    ) {
        self.url = url
        self.path = path
        self.params = params
        self.linkId = linkId
        self.matchType = matchType
        self.isDeferred = isDeferred
        self.campaign = campaign
    }
}

/// How the deferred / warm link was matched.
public enum MatchType: String, Sendable, Equatable {
    case installReferrer = "install_referrer"
    case clipboard
    case appClip = "app_clip"
    case claim
    case none

    public static func fromWire(_ value: String?) -> MatchType {
        guard let value else { return .none }
        return MatchType(rawValue: value) ?? .none
    }

    public var wireValue: String { rawValue }
}

/// Optional UTM / campaign attribution.
public struct Campaign: Sendable, Equatable, Hashable {
    public var values: [String: String]

    public init(_ values: [String: String] = [:]) {
        self.values = values
    }

    public var utmSource: String? { values["utm_source"] }
    public var utmCampaign: String? { values["utm_campaign"] }
}
