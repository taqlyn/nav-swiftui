# Taqlyn Nav Sample (SwiftUI)

Proof harness for `packages/nav-swiftui`. Imports **TaqlynNavSwiftUI only** — never UIPasteboard, URLSession, or TaqlynSDK types directly.

## Flow

1. Splash delay (stand-in for auth / onboarding)
2. Ready gate
3. Simulated deferred link `/product/123`
4. `DeepLinkNavigator.navigate` **replaces** `NavigationStack` path → Product
5. Second delivery of the same `linkId` → blocked (status text confirms)

## Wiring SdkCore (real app)

Copy fields from `TaqlynSDK.DeferredLink` into this package’s `DeferredLink`, navigate once, then consume:

```swift
for await sdkLink in SdkCore.observeLinks() {
  let link = DeferredLink(
    url: sdkLink.url,
    path: sdkLink.path,
    params: sdkLink.params,
    linkId: sdkLink.linkId,
    matchType: MatchType(rawValue: sdkLink.matchType.rawValue) ?? .none,
    isDeferred: sdkLink.isDeferred,
    campaign: sdkLink.campaign.map { Campaign($0.values) }
  )
  if navigator.navigate(link, path: &path) {
    SdkCore.consume(link.linkId)
  }
}
```

## Run notes

This folder is a lightweight source sketch (same pattern as `packages/sdk-ios/Samples`). Wire it into an Xcode app target that depends on the local `TaqlynNavSwiftUI` Swift package.
