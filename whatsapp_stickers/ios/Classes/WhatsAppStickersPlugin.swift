import Flutter
import UIKit

/**
 * Modern Swift implementation of WhatsApp Stickers plugin for iOS.
 * 
 * Uses async/await, Result types, and modern iOS patterns.
 */
public class WhatsAppStickersPlugin: NSObject, FlutterPlugin {
    
    private static let whatsAppURLScheme = "whatsapp://stickerPack"
    private static let pasteboardType = "net.whatsapp.third-party.sticker-pack"
    private static let pasteboardExpirationSeconds: TimeInterval = 60
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "whatsapp_stickers", binaryMessenger: registrar.messenger())
        let instance = WhatsAppStickersPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            switch call.method {
            case "addStickerPack":
                await handleAddStickerPack(call, result: result)
            case "isStickerPackInstalled":
                await handleIsStickerPackInstalled(call, result: result)
            case "isWhatsAppInstalled":
                await handleIsWhatsAppInstalled(result: result)
            case "validateStickerPack":
                await handleValidateStickerPack(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    @MainActor
    private func handleAddStickerPack(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String,
              let name = args["name"] as? String,
              let publisher = args["publisher"] as? String,
              let trayImageData = args["trayImageData"] as? FlutterStandardTypedData,
              let stickersData = args["stickers"] as? [[String: Any]] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing required arguments for sticker pack",
                details: nil
            ))
            return
        }
        
        do {
            let success = try await addStickerPackToWhatsApp(
                identifier: identifier,
                name: name,
                publisher: publisher,
                trayImageData: trayImageData.data,
                stickers: stickersData,
                publisherWebsite: args["publisherWebsite"] as? String,
                privacyPolicyWebsite: args["privacyPolicyWebsite"] as? String,
                licenseAgreementWebsite: args["licenseAgreementWebsite"] as? String
            )
            result(success)
        } catch let error as WhatsAppStickerError {
            result(FlutterError(
                code: error.code,
                message: error.message,
                details: error.details
            ))
        } catch {
            result(FlutterError(
                code: "UNEXPECTED_ERROR",
                message: "Unexpected error: \(error.localizedDescription)",
                details: error.localizedDescription
            ))
        }
    }
    
    @MainActor
    private func handleIsStickerPackInstalled(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
        // Note: iOS doesn't have a direct way to check if a sticker pack is installed
        // This would require the host app to maintain its own state
        result(false)
    }
    
    @MainActor
    private func handleIsWhatsAppInstalled(result: @escaping FlutterResult) async {
        let canOpenWhatsApp = await UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!)
        result(canOpenWhatsApp)
    }
    
    @MainActor
    private func handleValidateStickerPack(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
        // Validation is primarily done on the Dart side
        // Additional platform-specific validation can be added here
        result(true)
    }
    
    private func addStickerPackToWhatsApp(
        identifier: String,
        name: String,
        publisher: String,
        trayImageData: Data,
        stickers: [[String: Any]],
        publisherWebsite: String? = nil,
        privacyPolicyWebsite: String? = nil,
        licenseAgreementWebsite: String? = nil
    ) async throws -> Bool {
        
        // Check if WhatsApp can be opened
        guard await UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) else {
            throw WhatsAppStickerError.whatsAppNotInstalled
        }
        
        // Create JSON payload for WhatsApp
        var json: [String: Any] = [
            "identifier": identifier,
            "name": name,
            "publisher": publisher,
            "tray_image": trayImageData.base64EncodedString()
        ]
        
        // Add optional fields
        if let website = publisherWebsite, !website.isEmpty {
            json["publisher_website"] = website
        }
        if let privacyPolicy = privacyPolicyWebsite, !privacyPolicy.isEmpty {
            json["privacy_policy_website"] = privacyPolicy
        }
        if let licenseAgreement = licenseAgreementWebsite, !licenseAgreement.isEmpty {
            json["license_agreement_website"] = licenseAgreement
        }
        
        // Process stickers
        var stickersArray: [[String: Any]] = []
        for stickerData in stickers {
            guard let imageData = stickerData["imageData"] as? FlutterStandardTypedData,
                  let emojis = stickerData["emojis"] as? [String] else {
                continue
            }
            
            var stickerDict: [String: Any] = [
                "image_data": imageData.data.base64EncodedString(),
                "emojis": emojis
            ]
            
            if let accessibilityText = stickerData["accessibilityText"] as? String {
                stickerDict["accessibility_text"] = accessibilityText
            }
            
            stickersArray.append(stickerDict)
        }
        
        json["stickers"] = stickersArray
        
        // Send to WhatsApp via pasteboard
        return try await sendToWhatsApp(json: json)
    }
    
    private func sendToWhatsApp(json: [String: Any]) async throws -> Bool {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            throw WhatsAppStickerError.jsonSerializationFailed
        }
        
        // Set data on pasteboard
        let pasteboard = UIPasteboard.general
        
        if #available(iOS 10.0, *) {
            pasteboard.setItems(
                [[Self.pasteboardType: jsonData]], 
                options: [
                    .localOnly: true,
                    .expirationDate: Date(timeIntervalSinceNow: Self.pasteboardExpirationSeconds)
                ]
            )
        } else {
            pasteboard.setData(jsonData, forPasteboardType: Self.pasteboardType)
        }
        
        // Open WhatsApp
        guard let whatsAppURL = URL(string: Self.whatsAppURLScheme) else {
            throw WhatsAppStickerError.invalidWhatsAppURL
        }
        
        if #available(iOS 10.0, *) {
            await UIApplication.shared.open(whatsAppURL)
        } else {
            UIApplication.shared.openURL(whatsAppURL)
        }
        
        return true
    }
}

/**
 * Modern Swift error handling using enum with associated values.
 */
enum WhatsAppStickerError: Error {
    case whatsAppNotInstalled
    case jsonSerializationFailed
    case invalidWhatsAppURL
    case stickerPackValidationFailed(String)
    
    var code: String {
        switch self {
        case .whatsAppNotInstalled:
            return "WHATSAPP_NOT_INSTALLED"
        case .jsonSerializationFailed:
            return "JSON_SERIALIZATION_FAILED"
        case .invalidWhatsAppURL:
            return "INVALID_WHATSAPP_URL"
        case .stickerPackValidationFailed:
            return "VALIDATION_FAILED"
        }
    }
    
    var message: String {
        switch self {
        case .whatsAppNotInstalled:
            return "WhatsApp is not installed on this device"
        case .jsonSerializationFailed:
            return "Failed to serialize sticker pack data to JSON"
        case .invalidWhatsAppURL:
            return "Invalid WhatsApp URL scheme"
        case .stickerPackValidationFailed(let reason):
            return "Sticker pack validation failed: \(reason)"
        }
    }
    
    var details: String? {
        switch self {
        case .stickerPackValidationFailed(let reason):
            return reason
        default:
            return nil
        }
    }
}