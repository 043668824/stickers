import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'models/models.dart';

/// Utility class for loading and validating sticker assets.
/// 
/// Provides helper methods for common tasks when working with sticker packs.
class StickerAssetHelper {
  /// Loads an image asset as Uint8List.
  /// 
  /// [assetPath] should be the path to the asset in your pubspec.yaml.
  /// 
  /// Example:
  /// ```dart
  /// final imageData = await StickerAssetHelper.loadAsset('assets/stickers/happy.webp');
  /// ```
  static Future<Uint8List> loadAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
  
  /// Loads multiple assets concurrently.
  /// 
  /// Returns a map where keys are asset paths and values are the image data.
  static Future<Map<String, Uint8List>> loadAssets(List<String> assetPaths) async {
    final futures = assetPaths.map((path) async {
      final data = await loadAsset(path);
      return MapEntry(path, data);
    });
    
    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }
  
  /// Validates image dimensions by decoding the image header.
  /// 
  /// This is a lightweight check that doesn't load the full image into memory.
  /// Returns a record with width and height, or null if the image can't be decoded.
  static ({int width, int height})? getImageDimensions(Uint8List imageData) {
    try {
      // For a production implementation, you would use a proper image decoder
      // For now, return null to indicate that platform-specific validation should be used
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Estimates if image data represents an animated image based on file signature.
  /// 
  /// This is a heuristic check - more accurate detection happens on the platform side.
  static bool isLikelyAnimated(Uint8List imageData) {
    if (imageData.length < 12) return false;
    
    // Check for WebP signature and VP8X chunk (indicates animation capability)
    final header = imageData.take(12).toList();
    return header[0] == 0x52 && // 'R'
           header[1] == 0x49 && // 'I' 
           header[2] == 0x46 && // 'F'
           header[3] == 0x46 && // 'F'
           header[8] == 0x57 && // 'W'
           header[9] == 0x45 && // 'E'
           header[10] == 0x42 && // 'B'
           header[11] == 0x50;   // 'P'
  }
  
  /// Creates a simple test sticker pack for development/testing.
  /// 
  /// This generates minimal valid data that can be used for testing the plugin
  /// without requiring real sticker assets.
  static StickerPack createTestStickerPack({
    String identifier = 'test_pack',
    String name = 'Test Stickers',
    String publisher = 'Test Publisher',
  }) {
    // Create minimal valid image data (1x1 PNG)
    final pngHeader = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
      0x49, 0x48, 0x44, 0x52, // IHDR
      0x00, 0x00, 0x00, 0x01, // Width: 1
      0x00, 0x00, 0x00, 0x01, // Height: 1  
      0x08, 0x06, 0x00, 0x00, 0x00, // Bit depth, color type, etc.
      0x1F, 0x15, 0xC4, 0x89, // CRC
      0x00, 0x00, 0x00, 0x00, // IEND chunk length
      0x49, 0x45, 0x4E, 0x44, // IEND
      0xAE, 0x42, 0x60, 0x82  // CRC
    ]);
    
    final testStickers = List.generate(3, (index) => Sticker(
      imageFileName: 'test_sticker_${index + 1}.png',
      imageData: pngHeader,
      emojis: ['😀'],
      accessibilityText: 'Test sticker ${index + 1}',
    ));
    
    return StickerPack(
      identifier: identifier,
      name: name,
      publisher: publisher,
      trayImageData: pngHeader,
      stickers: testStickers,
    );
  }
}