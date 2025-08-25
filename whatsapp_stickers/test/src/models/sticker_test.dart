import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

void main() {
  group('Sticker', () {
    test('should create valid sticker with correct properties', () {
      final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final emojis = ['😀', '👋'];
      const accessibilityText = 'A happy face waving';
      
      final sticker = Sticker(
        imageFileName: 'test.webp',
        imageData: imageData,
        emojis: emojis,
        accessibilityText: accessibilityText,
      );
      
      expect(sticker.imageFileName, equals('test.webp'));
      expect(sticker.imageData, equals(imageData));
      expect(sticker.emojis, equals(emojis));
      expect(sticker.accessibilityText, equals(accessibilityText));
      expect(sticker.fileExtension, equals('webp'));
      expect(sticker.isAnimated, isTrue);
      expect(sticker.sizeInBytes, equals(5));
    });
    
    test('should detect file extension correctly', () {
      final pngSticker = Sticker(
        imageFileName: 'test.PNG',
        imageData: Uint8List(0),
        emojis: const ['😀'],
      );
      
      final webpSticker = Sticker(
        imageFileName: 'animated.webp',
        imageData: Uint8List(0),
        emojis: const ['😀'],
      );
      
      expect(pngSticker.fileExtension, equals('png'));
      expect(pngSticker.isAnimated, isFalse);
      expect(webpSticker.fileExtension, equals('webp'));
      expect(webpSticker.isAnimated, isTrue);
    });
    
    test('should validate sticker correctly', () {
      // Valid sticker
      final validSticker = Sticker(
        imageFileName: 'valid.webp',
        imageData: Uint8List(50000), // 50KB
        emojis: const ['😀', '👋'],
        accessibilityText: 'Short description',
      );
      
      final validation = validSticker.validate();
      expect(validation.isValid, isTrue);
      expect(validation.error, isNull);
    });
    
    test('should fail validation for unsupported format', () {
      final invalidSticker = Sticker(
        imageFileName: 'invalid.jpg',
        imageData: Uint8List(1000),
        emojis: const ['😀'],
      );
      
      final validation = invalidSticker.validate();
      expect(validation.isValid, isFalse);
      expect(validation.error, contains('Unsupported image format'));
    });
    
    test('should fail validation for too many emojis', () {
      final invalidSticker = Sticker(
        imageFileName: 'test.webp',
        imageData: Uint8List(1000),
        emojis: const ['😀', '👋', '❤️', '🎉'], // 4 emojis, max is 3
      );
      
      final validation = invalidSticker.validate();
      expect(validation.isValid, isFalse);
      expect(validation.error, contains('Too many emojis'));
    });
    
    test('should fail validation for file too large', () {
      final invalidSticker = Sticker(
        imageFileName: 'large.webp',
        imageData: Uint8List(600 * 1024), // 600KB, max is 500KB for animated
        emojis: const ['😀'],
      );
      
      final validation = invalidSticker.validate();
      expect(validation.isValid, isFalse);
      expect(validation.error, contains('exceeds maximum allowed size'));
    });
    
    test('should support copyWith functionality', () {
      final original = Sticker(
        imageFileName: 'original.webp',
        imageData: Uint8List.fromList([1, 2, 3]),
        emojis: const ['😀'],
      );
      
      final copied = original.copyWith(
        imageFileName: 'copied.webp',
        emojis: const ['👋'],
      );
      
      expect(copied.imageFileName, equals('copied.webp'));
      expect(copied.emojis, equals(const ['👋']));
      expect(copied.imageData, equals(original.imageData)); // Unchanged
    });
    
    test('should implement equality correctly', () {
      final sticker1 = Sticker(
        imageFileName: 'test.webp',
        imageData: Uint8List.fromList([1, 2, 3]),
        emojis: const ['😀'],
      );
      
      final sticker2 = Sticker(
        imageFileName: 'test.webp',
        imageData: Uint8List.fromList([1, 2, 3]),
        emojis: const ['😀'],
      );
      
      final sticker3 = Sticker(
        imageFileName: 'different.webp',
        imageData: Uint8List.fromList([1, 2, 3]),
        emojis: const ['😀'],
      );
      
      expect(sticker1, equals(sticker2));
      expect(sticker1, isNot(equals(sticker3)));
    });
  });
}