// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum CustomerFeedbackAsset {
  public static let icSmileyAwfulDeselected = CustomerFeedbackImages(name: "ic_smiley_awful_deselected")
  public static let icSmileyAwfulSelected = CustomerFeedbackImages(name: "ic_smiley_awful_selected")
  public static let icSmileyBadDeselected = CustomerFeedbackImages(name: "ic_smiley_bad_deselected")
  public static let icSmileyBadSelected = CustomerFeedbackImages(name: "ic_smiley_bad_selected")
  public static let icSmileyGoodDeselected = CustomerFeedbackImages(name: "ic_smiley_good_deselected")
  public static let icSmileyGoodSelected = CustomerFeedbackImages(name: "ic_smiley_good_selected")
  public static let icSmileyGreatDeselected = CustomerFeedbackImages(name: "ic_smiley_great_deselected")
  public static let icSmileyGreatSelected = CustomerFeedbackImages(name: "ic_smiley_great_selected")
  public static let icSmileyOkDeselected = CustomerFeedbackImages(name: "ic_smiley_ok_deselected")
  public static let icSmileyOkSelected = CustomerFeedbackImages(name: "ic_smiley_ok_selected")
  public static let feedbackBottom = CustomerFeedbackImages(name: "feedback_bottom")
  public static let feedbackTop = CustomerFeedbackImages(name: "feedback_top")
  public static let icCheckboxSelected = CustomerFeedbackImages(name: "ic_checkbox_selected")
  public static let icCheckboxUnselected = CustomerFeedbackImages(name: "ic_checkbox_unselected")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct CustomerFeedbackImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
	let bundle = Bundle.module
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension CustomerFeedbackImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the CustomerFeedbackImages.image property")
  convenience init?(asset: CustomerFeedbackImages) {
    #if os(iOS) || os(tvOS)
	let bundle = Bundle.module
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
