import Flutter
import UIKit

class DeviceLockPlugin: NSObject, FlutterPlugin {
    
    private var eventSink: FlutterEventSink?
    
    static let channelName = "com.deepfocus.focus_lock/device_lock"
    static let eventChannelName = "com.deepfocus.focus_lock/lock_events"
    
    static func register(with controller: FlutterViewController) {
        let methodChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )
        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: controller.binaryMessenger
        )
        
        let instance = DeviceLockPlugin()
        methodChannel.setMethodCallHandler(instance.handle)
        eventChannel.setStreamHandler(instance)
    }
    
    // Required by FlutterPlugin protocol
    static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = DeviceLockPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkPermissions":
            checkPermissions(result: result)
            
        case "requestUsageStatsPermission":
            // iOS doesn't have usage stats - use Screen Time API
            requestScreenTimePermission(result: result)
            
        case "requestOverlayPermission":
            // iOS doesn't have overlay permission concept
            result(true)
            
        case "startMonitoring":
            startMonitoring(call: call, result: result)
            
        case "stopMonitoring":
            stopMonitoring(result: result)
            
        case "getInstalledApps":
            getInstalledApps(result: result)
            
        case "enableImmersiveMode":
            enableImmersiveMode(result: result)
            
        case "disableImmersiveMode":
            disableImmersiveMode(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Permissions
    
    private func checkPermissions(result: @escaping FlutterResult) {
        var permissions: [String: Bool] = [
            "usageStats": false,
            "overlay": true, // iOS always true (no concept of overlay permission)
            "camera": false
        ]
        
        // Check camera
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        permissions["camera"] = cameraStatus == .authorized
        
        // Check Screen Time (FamilyControls) - iOS 15+
        if #available(iOS 16.0, *) {
            // FamilyControls availability check
            permissions["usageStats"] = checkFamilyControlsAuthorization()
        } else {
            permissions["usageStats"] = false
        }
        
        result(permissions)
    }
    
    @available(iOS 16.0, *)
    private func checkFamilyControlsAuthorization() -> Bool {
        // FamilyControls requires specific entitlement
        // For development, we return false and show Guided Access fallback
        return false
    }
    
    private func requestScreenTimePermission(result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            requestFamilyControlsAuth(result: result)
        } else {
            // Fallback: show guided access instructions
            result(false)
        }
    }
    
    @available(iOS 16.0, *)
    private func requestFamilyControlsAuth(result: @escaping FlutterResult) {
        // FamilyControls authorization requires:
        // 1. com.apple.developer.family-controls entitlement
        // 2. User approval via FamilyControls.AuthorizationCenter
        //
        // This entitlement must be requested from Apple.
        // For now, we return false and the Flutter side shows
        // Guided Access mode instructions as a fallback.
        
        // Uncomment when entitlement is approved:
        /*
        import FamilyControls
        
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                result(true)
            } catch {
                result(false)
            }
        }
        */
        
        result(false)
    }
    
    // MARK: - Monitoring
    
    private func startMonitoring(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // iOS app monitoring requires FamilyControls + DeviceActivity frameworks
        // These require the restricted entitlement from Apple.
        //
        // For development, the Flutter side handles lock screen behavior
        // and the user is instructed to use Guided Access mode.
        //
        // When entitlement is available:
        // 1. Use DeviceActivitySchedule to set monitoring intervals
        // 2. Use ShieldConfiguration to block apps
        // 3. Use ManagedSettingsStore to apply restrictions
        
        result(true)
    }
    
    private func stopMonitoring(result: @escaping FlutterResult) {
        // Clear any DeviceActivity schedules and ManagedSettings stores
        result(true)
    }
    
    // MARK: - Installed Apps
    
    private func getInstalledApps(result: @escaping FlutterResult) {
        // iOS doesn't allow querying installed apps for privacy.
        // We return a curated list of common distracting apps.
        let apps: [[String: Any]] = [
            ["packageName": "com.burbn.instagram", "appName": "Instagram", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.zhiliaoapp.musically", "appName": "TikTok", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.facebook.Facebook", "appName": "Facebook", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.atebits.Tweetie2", "appName": "Twitter / X", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.toyopagroup.picaboo", "appName": "Snapchat", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.google.ios.youtube", "appName": "YouTube", "category": "Entertainment", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.reddit.Reddit", "appName": "Reddit", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "net.whatsapp.WhatsApp", "appName": "WhatsApp", "category": "Communication", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "ph.telegra.Telegraph", "appName": "Telegram", "category": "Communication", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.hammerandchisel.discord", "appName": "Discord", "category": "Communication", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.netflix.Netflix", "appName": "Netflix", "category": "Entertainment", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "tv.twitch", "appName": "Twitch", "category": "Entertainment", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.spotify.client", "appName": "Spotify", "category": "Music", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.pinterest", "appName": "Pinterest", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.linkedin.LinkedIn", "appName": "LinkedIn", "category": "Social", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.facebook.Messenger", "appName": "Messenger", "category": "Communication", "isBlocked": false, "isWhitelisted": false],
            ["packageName": "com.apple.mobilesafari", "appName": "Safari", "category": "Browser", "isBlocked": false, "isWhitelisted": false],
        ]
        
        result(apps)
    }
    
    // MARK: - Immersive Mode
    
    private func enableImmersiveMode(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Hide status bar
                if let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
        result(true)
    }
    
    private func disableImmersiveMode(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
        result(true)
    }
}

// MARK: - Event Channel Stream Handler
extension DeviceLockPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - AVFoundation Import for Camera Check
import AVFoundation
