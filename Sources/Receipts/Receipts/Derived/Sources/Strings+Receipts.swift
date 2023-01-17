// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum ReceiptsStrings {
  /// Sorry, error from receipt server, try again later
  public static let errorReceiptsUnavailableBody = ReceiptsStrings.tr("Receipts", "error_receipts_unavailable_body")
  /// Error
  public static let errorReceiptsUnavailableTitle = ReceiptsStrings.tr("Receipts", "error_receipts_unavailable_title")
  /// You have no receipts from this month
  public static let receiptsEmptyMonthText = ReceiptsStrings.tr("Receipts", "receipts_empty_month_text")
  /// You have no receipts
  public static let receiptsNoDataText = ReceiptsStrings.tr("Receipts", "receipts_no_data_text")
  /// Your Receipts
  public static let receiptsScreenTitle = ReceiptsStrings.tr("Receipts", "receipts_screen_title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension ReceiptsStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
	  let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
