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

Add `TaqlynNavSwiftUI` to your `Podfile` (`iOS 16.0+` with `use_frameworks!`):

```ruby
platform :ios, '16.0'
use_frameworks!

target 'MyApp' do
  # Core Taqlyn SDK:
  pod 'TaqlynSDK', '~> 0.1.0'
  # SwiftUI navigation stack binding:
  pod 'TaqlynNavSwiftUI', '~> 0.1.0'
end
```

Then run:

```bash
pod install --repo-update
```

Open the generated `.xcworkspace` in Xcode (never open the `.xcodeproj` directly).

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

## CI/CD & SPM Distribution

Published via `.github/workflows/publish.yml`:
- **Swift Package Manager (SPM):** Xcode and `swift package` resolve directly from Git release tags (`v*`). **Zero secrets required.**
- **CocoaPods Trunk (Optional):** Automatically validates podspec and pushes to CocoaPods Trunk when `COCOAPODS_TRUNK_TOKEN` is present in GitHub Secrets.

## CocoaPods Publishing & Trunk Submission Guide

`TaqlynNavSwiftUI` is officially published to CocoaPods Trunk ([cocoapods.org/pods/TaqlynNavSwiftUI](https://cocoapods.org/pods/TaqlynNavSwiftUI)) using `TaqlynNavSwiftUI.podspec`.

### 1. Specification Overview
- **Platform:** `iOS 16.0+`, Swift `5.9+`.
- **Frameworks:** `SwiftUI`.
- **Git tag matching:** The podspec defines `:git => 'https://github.com/taqlyn/nav-swiftui.git', :tag => "v#{s.version}"`. The Git release tag must use the `v` prefix (e.g. `v0.1.0`).
- **Decoupled Architecture:** `TaqlynNavSwiftUI` has zero direct dependencies on `TaqlynSDK` in its podspec — consumers map data structures at the app boundary.

### 2. Pre-Submission Linting & Validation
Run verification commands from `packages/nav-swiftui`:

```bash
# Fast JSON AST validation (checks syntax without Xcode build)
pod ipc spec TaqlynNavSwiftUI.podspec > /dev/null

# Local workspace validation (validates local swift source files)
pod lib lint TaqlynNavSwiftUI.podspec --allow-warnings

# Remote tag validation (validates that Git tag exists on GitHub and builds in a clean environment)
pod spec lint TaqlynNavSwiftUI.podspec --allow-warnings
```

### 3. Git Release Tagging
Commit all changes and push the semantic release tag to GitHub:

```bash
git tag v0.1.0
git push origin v0.1.0
```

### 4. CocoaPods Trunk Account Registration
CocoaPods uses email-based passwordless session authorization:

```bash
# Register maintainer email on Trunk (first-time only)
pod trunk register dev@taqlyn.com "Taqlyn Platform Team" --description="Taqlyn Release Machine"

# Click confirmation link in the verification email, then confirm:
pod trunk me
```

### 5. Publishing to CocoaPods Trunk
After pushing the Git release tag and validating:

```bash
pod trunk push TaqlynNavSwiftUI.podspec --allow-warnings
```

### 6. Automated CI/CD Publishing
This repository automates CocoaPods publishing via `.github/workflows/publish.yml`:
1. Retrieve trunk token:
   ```bash
   pod trunk print-token
   ```
2. Save token as GitHub repository secret: `COCOAPODS_TRUNK_TOKEN`.
3. Pushing a tag `v*` triggers the workflow:
   - Validates `Package.swift` and runs SPM tests.
   - If `COCOAPODS_TRUNK_TOKEN` is present, lints `TaqlynNavSwiftUI.podspec` and pushes to Trunk automatically.

### 7. Managing Owners & Collaborators
Grant team members access to manage the pod:

```bash
# Add co-maintainer
pod trunk add-owner TaqlynNavSwiftUI teammate@taqlyn.com

# Inspect owners and version history
pod trunk info TaqlynNavSwiftUI
```

### 8. Troubleshooting & Common Pitfalls
- **`[!] The tag does not exist`:** Push the tag to GitHub first: `git push origin v0.1.0`.
- **`[!] Pod not found in consumer project`:** CocoaPods CDN takes a few minutes to index new versions. Run `pod install --repo-update`.
- **`[!] Framework not found SwiftUI`:** Ensure consumer `Podfile` declares `platform :ios, '16.0'` or higher and specifies `use_frameworks!`.

