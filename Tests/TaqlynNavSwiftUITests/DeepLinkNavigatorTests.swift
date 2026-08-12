import XCTest
@testable import TaqlynNavSwiftUI

private enum SampleRoute: Hashable {
    case home
    case product(String)
}

final class DeepLinkNavigatorTests: XCTestCase {
    func testNavigate_replacesPathWithMappedRoutes() {
        let navigator = DeepLinkNavigator<SampleRoute> { link in
            guard link.path.hasPrefix("/product/") else { return nil }
            let id = String(link.path.dropFirst("/product/".count))
            return [.home, .product(id)]
        }
        var path: [SampleRoute] = [.home]
        let link = makeLink(path: "/product/123", linkId: "lnk_1")

        let ok = navigator.navigate(link, path: &path)

        XCTAssertTrue(ok)
        XCTAssertEqual(path, [.home, .product("123")])
        XCTAssertEqual(navigator.lastLinkId, "lnk_1")
    }

    func testNavigate_sameLinkId_returnsFalseAndLeavesPathUnchanged() {
        let navigator = DeepLinkNavigator<SampleRoute> { _ in [.product("123")] }
        var path: [SampleRoute] = []
        let link = makeLink(path: "/product/123", linkId: "lnk_same")

        XCTAssertTrue(navigator.navigate(link, path: &path))
        path = [.home, .product("999")]

        let second = navigator.navigate(link, path: &path)

        XCTAssertFalse(second)
        XCTAssertEqual(path, [.home, .product("999")])
    }

    func testNavigate_differentLinkId_canNavigateAgain() {
        let navigator = DeepLinkNavigator<SampleRoute> { link in
            let id = String(link.path.dropFirst("/product/".count))
            return [.product(id)]
        }
        var path: [SampleRoute] = []

        XCTAssertTrue(navigator.navigate(makeLink(path: "/product/1", linkId: "lnk_a"), path: &path))
        XCTAssertEqual(path, [.product("1")])

        XCTAssertTrue(navigator.navigate(makeLink(path: "/product/2", linkId: "lnk_b"), path: &path))
        XCTAssertEqual(path, [.product("2")])
        XCTAssertEqual(navigator.lastLinkId, "lnk_b")
    }

    func testNavigate_nilMapper_returnsFalse() {
        let navigator = DeepLinkNavigator<SampleRoute> { _ in nil }
        var path: [SampleRoute] = [.home]
        let before = path

        let ok = navigator.navigate(makeLink(path: "/unknown", linkId: "lnk_nil"), path: &path)

        XCTAssertFalse(ok)
        XCTAssertEqual(path, before)
        XCTAssertNil(navigator.lastLinkId)
    }

    func testNavigate_emptyMapper_returnsFalse() {
        let navigator = DeepLinkNavigator<SampleRoute> { _ in [] }
        var path: [SampleRoute] = [.home]

        XCTAssertFalse(navigator.navigate(makeLink(path: "/x", linkId: "lnk_empty"), path: &path))
        XCTAssertEqual(path, [.home])
    }

    func testClearConsumed_allowsSameLinkIdAgain() {
        let navigator = DeepLinkNavigator<SampleRoute> { _ in [.product("1")] }
        var path: [SampleRoute] = []
        let link = makeLink(path: "/product/1", linkId: "lnk_again")

        XCTAssertTrue(navigator.navigate(link, path: &path))
        navigator.clearConsumed()
        path = []
        XCTAssertTrue(navigator.navigate(link, path: &path))
        XCTAssertEqual(path, [.product("1")])
    }

    private func makeLink(path: String, linkId: String) -> DeferredLink {
        DeferredLink(
            url: "https://example.test\(path)",
            path: path,
            params: [:],
            linkId: linkId,
            matchType: .clipboard,
            isDeferred: true
        )
    }
}

/// Library sources must stay free of pasteboard / network vendor kits.
final class LibrarySourceGuardTests: XCTestCase {
    func testLibrarySources_doNotImportPasteboardOrNetwork() throws {
        let root = try locateLibraryRoot()
        let files = try walkSwiftSources(under: root)
        XCTAssertFalse(files.isEmpty, "expected library Swift sources under \(root.path)")

        let forbidden = [
            "UIPasteboard",
            "UIKit.UIPasteboard",
            "URLSession",
            "import UIKit",
            "import Network",
        ]
        var offenders: [String] = []
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for needle in forbidden {
                if text.contains(needle) {
                    offenders.append("\(file.lastPathComponent) contains \(needle)")
                }
            }
        }
        XCTAssertTrue(offenders.isEmpty, offenders.joined(separator: "\n"))
    }

    private func locateLibraryRoot() throws -> URL {
        let fm = FileManager.default
        let cwd = URL(fileURLWithPath: fm.currentDirectoryPath, isDirectory: true)
        let candidates = [
            cwd.appendingPathComponent("Sources/TaqlynNavSwiftUI"),
            cwd.appendingPathComponent("../Sources/TaqlynNavSwiftUI"),
            cwd.appendingPathComponent("packages/nav-swiftui/Sources/TaqlynNavSwiftUI"),
        ]
        if let hit = candidates.first(where: { fm.fileExists(atPath: $0.path) }) {
            return hit
        }
        throw XCTSkip("Sources/TaqlynNavSwiftUI not found from \(cwd.path)")
    }

    private func walkSwiftSources(under root: URL) throws -> [URL] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        var results: [URL] = []
        for case let url as URL in enumerator {
            if url.pathExtension == "swift" {
                results.append(url)
            }
        }
        return results
    }
}
