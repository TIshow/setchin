import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
      // Xcode の環境変数から APIキー を取得
      if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"], !apiKey.isEmpty {
          GMSServices.provideAPIKey(apiKey)
      } else {
          fatalError("Google Maps API Key is missing. Please set GOOGLE_MAPS_API_KEY in Xcode's Environment Variables.")
      }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
