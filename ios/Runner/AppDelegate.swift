import Flutter
import UIKit
import WidgetKit

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
<<<<<<< HEAD
        let defaults = UserDefaults(suiteName: "group.com.dontsmoke.com")
=======
        let defaults = UserDefaults(suiteName: "group.com.dontsmoke.kz")
>>>>>>> 669c699421a26ce79164e8b247a3be3fb3a62238
        defaults?.set(args["quit_date_millis"] as? Int64 ?? -1, forKey: "quit_date_millis")
        defaults?.set(args["cigarettes_per_day"] as? Int ?? 0, forKey: "cigarettes_per_day")
        defaults?.set(args["cost_per_pack"] as? Int ?? 0, forKey: "cost_per_pack")
        defaults?.set(args["cigarettes_per_pack"] as? Int ?? 20, forKey: "cigarettes_per_pack")
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)

      case "clearWidgetData":
<<<<<<< HEAD
        let defaults = UserDefaults(suiteName: "group.com.dontsmoke.com")
=======
        let defaults = UserDefaults(suiteName: "group.com.dontsmoke.kz")
>>>>>>> 669c699421a26ce79164e8b247a3be3fb3a62238
        for key in ["quit_date_millis", "cigarettes_per_day", "cost_per_pack", "cigarettes_per_pack"] {
          defaults?.removeObject(forKey: key)
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
