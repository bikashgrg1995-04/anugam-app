import UIKit
import Flutter
import GoogleMaps // <-- Import Google Maps SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Provide your Google Maps API key here
    GMSServices.provideAPIKey("AIzaSyCMNHbEEQY_eFaKaBMK8Qu9fnWPIWyzjf0")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
