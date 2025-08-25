import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

void main() {
  group('StickerAssetHelper', () {
    test('should detect animated images correctly', () {
      // WebP signature: RIFF....WEBP
      final webpData = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, // RIFF
        0x00, 0x00, 0x00, 0x00, // File size (placeholder)
        0x57, 0x45, 0x42, 0x50, // WEBP
        // Additional data...
      ]);
      
      final isAnimated = StickerAssetHelper.isLikelyAnimated(webpData);
      expect(isAnimated, isTrue);
      
      final pngData = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, // PNG signature
        0x0D, 0x0A, 0x1A, 0x0A,
      ]);
      
      final isPngAnimated = StickerAssetHelper.isLikelyAnimated(pngData);
      expect(isPngAnimated, isFalse);
    });
    
    test('should create valid test sticker pack', () {
      final testPack = StickerAssetHelper.createTestStickerPack(
        identifier: 'custom_test',
        name: 'Custom Test Pack',
        publisher: 'Test Publisher',
      );
      
      expect(testPack.identifier, equals('custom_test'));
      expect(testPack.name, equals('Custom Test Pack'));
      expect(testPack.publisher, equals('Test Publisher'));
      expect(testPack.stickers.length, equals(3));
      
      final validation = testPack.validate();
      expect(validation.isValid, isTrue);
    });
    
    test('should handle invalid image data gracefully', () {
      final invalidData = Uint8List.fromList([1, 2, 3]); // Too short
      final isAnimated = StickerAssetHelper.isLikelyAnimated(invalidData);
      expect(isAnimated, isFalse);
    });
  });
}