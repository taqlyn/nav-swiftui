# Taqlyn SwiftUI Nav (`nav-swiftui`)

Optional NavigationStack adapter for Taqlyn deferred / warm links.

**Versions independently from SdkCore** (`sdk-ios` / TaqlynSDK). Apps depend on both packages and map payloads at the boundary — this library never imports TaqlynSDK, UIPasteboard, or URLSession.

## Modules

| Path | Role |
|------|------|
| `Sources/TaqlynNavSwiftUI/` | `DeferredLink` + `DeepLinkNavigator` |
| `Samples/TaqlynNavSample/` | SwiftUI sketch (splash → ready → navigate once) |
| `Tests/TaqlynNavSwiftUITests/` | Navigate / dedupe / source-guard tests |

## Public API

```swift
public struct DeferredLink { url, path, params, linkId, matchType, isDeferred, campaign? }

public final class DeepLinkNavigator<Route: Hashable>: @unchecked Sendable {
  public init(map: @escaping (DeferredLink) -> [Route]?)
  @discardableResult
  public func navigate(_ link: DeferredLink, path: inout [Route]) -> Bool
  public func clearConsumed()
}
```

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies...**, enter `https://github.com/taqlyn/nav-swiftui.git`, and select `TaqlynNavSwiftUI`.

### CocoaPods

In your `Podfile`:

```ruby
pod 'TaqlynNavSwiftUI', '~> 0.1.0'
```

- On success, `path` is **replaced** with the mapped routes (not appended).
- Returns `false` if the mapper returns `nil`/empty, or the same `linkId` already navigated.
- Bind `@State var path: [Route]` to `NavigationStack(path: $path)`.

## Mapping from TaqlynSDK

```swift
let navLink = DeferredLink(
  url: sdkLink.url,
  path: sdkLink.path,
  params: sdkLink.params,
  linkId: sdkLink.linkId,
  matchType: MatchType(rawValue: sdkLink.matchType.rawValue) ?? .none,
  isDeferred: sdkLink.isDeferred,
  campaign: sdkLink.campaign.map { Campaign($0.values) }
)
```

## Ready-gate → navigate once → consume

1. Hold until auth / onboarding calls `SdkCore.setReadyForNavigation(true)`.
2. On `observeLinks` delivery, map → `navigator.navigate(link, path: &path)`.
3. On success, `SdkCore.consume(link.linkId)`.
4. A second delivery of the same `linkId` is ignored by the navigator (and by SdkCore after consume).

## Non-goals

- No resolve HTTP / `URLSession`
- No `UIPasteboard` / Install Referrer
- No dependency on TaqlynSDK — own `DeferredLink` mirroring `packages/sdk-contract`

## Tests

```bash
cd packages/nav-swiftui && swift test
```
