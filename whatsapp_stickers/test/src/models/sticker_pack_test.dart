import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

void main() {
  group('StickerPack', () {
    late List<Sticker> validStickers;
    late Uint8List validTrayImage;
    
    setUp(() {
      // Create minimal valid stickers for testing
      validStickers = List.generate(3, (index) => Sticker(
        imageFileName: 'sticker_${index + 1}.webp',
        imageData: Uint8List(50000), // 50KB
        emojis: ['😀'],
        accessibilityText: 'Test sticker ${index + 1}',
      ));
      
      validTrayImage = Uint8List(30000); // 30KB
    });
    
    test('should create valid sticker pack', () {
      final stickerPack = StickerPack(
        identifier: 'test_pack',
        name: 'Test Pack',
        publisher: 'Test Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      expect(stickerPack.identifier, equals('test_pack'));
      expect(stickerPack.name, equals('Test Pack'));
      expect(stickerPack.publisher, equals('Test Publisher'));
      expect(stickerPack.stickers.length, equals(3));
      expect(stickerPack.isAnimated, isTrue); // webp stickers
    });
    
    test('should calculate total size correctly', () {
      final stickerPack = StickerPack(
        identifier: 'test_pack',
        name: 'Test Pack',
        publisher: 'Test Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      final expectedSize = validTrayImage.length + 
                          validStickers.fold(0, (sum, sticker) => sum + sticker.sizeInBytes);
      
      expect(stickerPack.totalSizeInBytes, equals(expectedSize));
    });
    
    test('should format size correctly', () {
      final smallPack = StickerPack(
        identifier: 'small_pack',
        name: 'Small Pack',
        publisher: 'Publisher',
        trayImageData: Uint8List(1000), // 1KB
        stickers: [Sticker(
          imageFileName: 'small.webp',
          imageData: Uint8List(500), // 0.5KB
          emojis: const ['😀'],
        )],
      );
      
      expect(smallPack.formattedSize, contains('KB'));
      
      final largePack = StickerPack(
        identifier: 'large_pack',
        name: 'Large Pack',
        publisher: 'Publisher',
        trayImageData: Uint8List(50000),
        stickers: List.generate(30, (index) => Sticker(
          imageFileName: 'large_$index.webp',
          imageData: Uint8List(100000), // 100KB each
          emojis: const ['😀'],
        )),
      );
      
      expect(largePack.formattedSize, contains('MB'));
    });
    
    test('should validate correctly with valid data', () {
      final stickerPack = StickerPack(
        identifier: 'valid_pack',
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
        publisherEmail: 'test@example.com',
        publisherWebsite: 'https://example.com',
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });
    
    test('should fail validation with empty identifier', () {
      final stickerPack = StickerPack(
        identifier: '', // Empty identifier
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isFalse);
      expect(validation.errors, contains(contains('Identifier cannot be empty')));
    });
    
    test('should fail validation with too few stickers', () {
      final stickerPack = StickerPack(
        identifier: 'valid_pack',
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: [validStickers.first], // Only 1 sticker, min is 3
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isFalse);
      expect(validation.errors, contains(contains('Not enough stickers')));
    });
    
    test('should fail validation with too many stickers', () {
      final tooManyStickers = List.generate(35, (index) => Sticker(
        imageFileName: 'sticker_$index.webp',
        imageData: Uint8List(1000),
        emojis: const ['😀'],
      ));
      
      final stickerPack = StickerPack(
        identifier: 'valid_pack',
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: tooManyStickers, // 35 stickers, max is 30
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isFalse);
      expect(validation.errors, contains(contains('Too many stickers')));
    });
    
    test('should fail validation with invalid URL', () {
      final stickerPack = StickerPack(
        identifier: 'valid_pack',
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
        publisherWebsite: 'not-a-valid-url',
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isFalse);
      expect(validation.errors, contains(contains('not a valid URL')));
    });
    
    test('should fail validation with invalid email', () {
      final stickerPack = StickerPack(
        identifier: 'valid_pack',
        name: 'Valid Pack',
        publisher: 'Valid Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
        publisherEmail: 'not-an-email',
      );
      
      final validation = stickerPack.validate();
      expect(validation.isValid, isFalse);
      expect(validation.errors, contains(contains('email is not valid')));
    });
    
    test('should support copyWith functionality', () {
      final original = StickerPack(
        identifier: 'original',
        name: 'Original Pack',
        publisher: 'Original Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      final copied = original.copyWith(
        name: 'Copied Pack',
        publisher: 'New Publisher',
      );
      
      expect(copied.identifier, equals('original')); // Unchanged
      expect(copied.name, equals('Copied Pack')); // Changed
      expect(copied.publisher, equals('New Publisher')); // Changed
      expect(copied.stickers, equals(original.stickers)); // Unchanged
    });
    
    test('should implement equality correctly', () {
      final pack1 = StickerPack(
        identifier: 'test',
        name: 'Test',
        publisher: 'Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      final pack2 = StickerPack(
        identifier: 'test',
        name: 'Test',
        publisher: 'Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      final pack3 = StickerPack(
        identifier: 'different',
        name: 'Test',
        publisher: 'Publisher',
        trayImageData: validTrayImage,
        stickers: validStickers,
      );
      
      expect(pack1, equals(pack2));
      expect(pack1, isNot(equals(pack3)));
    });
  });
}