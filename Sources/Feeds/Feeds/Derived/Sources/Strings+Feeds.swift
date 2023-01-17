// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum FeedsStrings {
  /// Today %@
  public static func newsFeedTodayDate(_ p1: Any) -> String {
    return FeedsStrings.tr("Feeds", "news_feed_today_date", String(describing: p1))
  }
  /// The video cannot be played.
  public static let newsFeedVideoErrorMessage = FeedsStrings.tr("Feeds", "news_feed_video_error_message")
  /// Yesterday %@
  public static func newsFeedYesterdayDate(_ p1: Any) -> String {
    return FeedsStrings.tr("Feeds", "news_feed_yesterday_date", String(describing: p1))
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension FeedsStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = FeedsResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
