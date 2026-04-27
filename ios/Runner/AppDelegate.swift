import Flutter
import UIKit
import WidgetKit

private let widgetAppGroup = "group.kz.dontsmoke.app"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.dontsmoke.kz/widget",
                                       binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "saveWidgetData":
        guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
          return
        }
        guard let defaults = UserDefaults(suiteName: widgetAppGroup) else {
          result(FlutterError(code: "APP_GROUP_UNAVAILABLE", message: nil, details: nil))
          return
        }
        defaults.set(int64Value(args["quit_date_millis"], fallback: -1), forKey: "quit_date_millis")
        defaults.set(intValue(args["cigarettes_per_day"], fallback: 0), forKey: "cigarettes_per_day")
        defaults.set(intValue(args["cost_per_pack"], fallback: 0), forKey: "cost_per_pack")
        defaults.set(intValue(args["cigarettes_per_pack"], fallback: 20), forKey: "cigarettes_per_pack")
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)

      case "clearWidgetData":
        guard let defaults = UserDefaults(suiteName: widgetAppGroup) else {
          result(FlutterError(code: "APP_GROUP_UNAVAILABLE", message: nil, details: nil))
          return
        }
        for key in ["quit_date_millis", "cigarettes_per_day", "cost_per_pack", "cigarettes_per_pack"] {
          defaults.removeObject(forKey: key)
        }
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func intValue(_ value: Any?, fallback: Int) -> Int {
  if let value = value as? Int { return value }
  if let value = value as? Int64 { return Int(value) }
  if let value = value as? NSNumber { return value.intValue }
  if let value = value as? String, let parsed = Int(value) { return parsed }
  return fallback
}

private func int64Value(_ value: Any?, fallback: Int64) -> Int64 {
  if let value = value as? Int64 { return value }
  if let value = value as? Int { return Int64(value) }
  if let value = value as? NSNumber { return value.int64Value }
  if let value = value as? String, let parsed = Int64(value) { return parsed }
  return fallback
}
