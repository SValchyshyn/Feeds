// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
import Foundation

// MARK: - Swift Bundle Accessor

private class BundleFinder {}

extension Foundation.Bundle {
    /// Since Receipts is a framework, the bundle containing the resources is copied into the final product.
    static var Receipts: Bundle = {
        return Bundle(for: BundleFinder.self)
    }()
}

// MARK: - Objective-C Bundle Accessor

//@objc
//public class ReceiptsResources: NSObject {
//   @objc public class var bundle: Bundle {
//         return .module
//   }
//}
// swiftlint:enable all
// swiftformat:enable all
