import SwiftUI
import TaqlynNavSwiftUI

enum AppRoute: Hashable {
    case home
    case product(String)
}

/// Feature sketch: splash → ready → deferred `/product/123` → navigate once.
///
/// Wire SdkCore in a real app by copying fields into this package's `DeferredLink`,
/// calling `navigator.navigate`, then `SdkCore.consume(link.linkId)`.
struct ContentView: View {
    @State private var path: [AppRoute] = []
    @State private var status = "Splash…"
    @State private var ready = false

    private let navigator = DeepLinkNavigator<AppRoute> { link in
        if link.path.hasPrefix("/product/") {
            let id = String(link.path.dropFirst("/product/".count))
            guard !id.isEmpty else { return nil }
            return [.product(id)]
        }
        if link.path == "/" || link.path == "/home" {
            return [.home]
        }
        return nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Taqlyn Nav Sample")
                    .font(.title2.bold())
                Text(status)
                    .font(.body)
                Text("Stack: \(pathDescription)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home:
                    Text("Home")
                case .product(let id):
                    Text("Product \(id)")
                        .font(.title)
                }
            }
        }
        .task {
            // Splash → ready gate (mirrors SdkCore.setReadyForNavigation).
            try? await Task.sleep(nanoseconds: 200_000_000)
            ready = true
            status = "Ready — delivering deferred link…"

            let deferred = DeferredLink(
                url: "https://go.example.test/product/123",
                path: "/product/123",
                params: ["sku": "123"],
                linkId: "lnk_demo_123",
                matchType: .clipboard,
                isDeferred: true,
                campaign: Campaign(["utm_source": "invite"])
            )

            guard ready else { return }

            let first = navigator.navigate(deferred, path: &path)
            status = first
                ? "Navigated to product/123 (linkId=\(deferred.linkId))"
                : "First navigate failed"

            // Second delivery of the same linkId must not double-navigate.
            let before = path
            let second = navigator.navigate(deferred, path: &path)
            if !second, path == before {
                status += "\nSecond delivery same linkId → blocked (no double navigation)"
            } else {
                status += "\nERROR: second delivery should have been blocked"
            }

            // In a real app after navigate:
            // SdkCore.consume(deferred.linkId)
        }
    }

    private var pathDescription: String {
        if path.isEmpty { return "(root)" }
        return path.map { route in
            switch route {
            case .home: return "home"
            case .product(let id): return "product(\(id))"
            }
        }.joined(separator: " → ")
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
