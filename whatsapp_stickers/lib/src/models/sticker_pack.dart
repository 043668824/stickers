import 'dart:typed_data';
import 'sticker.dart';
import 'validation_limits.dart';

/// Represents a collection of stickers that can be added to WhatsApp.
/// 
/// Uses modern Dart 3 features and provides comprehensive validation.
class StickerPack {
  /// Creates a new sticker pack with the provided metadata and stickers.
  const StickerPack({
    required this.identifier,
    required this.name,
    required this.publisher,
    required this.trayImageData,
    required this.stickers,
    this.publisherEmail,
    this.publisherWebsite,
    this.privacyPolicyWebsite,
    this.licenseAgreementWebsite,
    this.imageDataVersion = '1',
    this.avoidCache = false,
  });
  
  /// Unique identifier for this sticker pack.
  final String identifier;
  
  /// Display name of the sticker pack.
  final String name;
  
  /// Publisher/creator of the sticker pack.
  final String publisher;
  
  /// Tray image data (96x96 PNG, max 50KB).
  final Uint8List trayImageData;
  
  /// List of stickers in this pack (3-30 stickers).
  final List<Sticker> stickers;
  
  /// Optional publisher email address.
  final String? publisherEmail;
  
  /// Optional publisher website URL.
  final String? publisherWebsite;
  
  /// Optional privacy policy website URL.
  final String? privacyPolicyWebsite;
  
  /// Optional license agreement website URL.
  final String? licenseAgreementWebsite;
  
  /// Version of the image data format (default: '1').
  final String imageDataVersion;
  
  /// Whether to avoid caching (default: false).
  final bool avoidCache;
  
  /// Whether this pack contains animated stickers.
  bool get isAnimated => stickers.any((sticker) => sticker.isAnimated);
  
  /// Total size of all stickers in bytes.
  int get totalSizeInBytes => 
    trayImageData.length + stickers.fold(0, (sum, sticker) => sum + sticker.sizeInBytes);
  
  /// Formatted size string for display.
  String get formattedSize {
    final sizeKb = totalSizeInBytes / 1024;
    if (sizeKb < 1024) {
      return '${sizeKb.toStringAsFixed(1)} KB';
    } else {
      final sizeMb = sizeKb / 1024;
      return '${sizeMb.toStringAsFixed(1)} MB';
    }
  }
  
  /// Creates a copy of this sticker pack with updated properties.
  StickerPack copyWith({
    String? identifier,
    String? name,
    String? publisher,
    Uint8List? trayImageData,
    List<Sticker>? stickers,
    String? publisherEmail,
    String? publisherWebsite,
    String? privacyPolicyWebsite,
    String? licenseAgreementWebsite,
    String? imageDataVersion,
    bool? avoidCache,
  }) {
    return StickerPack(
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      trayImageData: trayImageData ?? this.trayImageData,
      stickers: stickers ?? this.stickers,
      publisherEmail: publisherEmail ?? this.publisherEmail,
      publisherWebsite: publisherWebsite ?? this.publisherWebsite,
      privacyPolicyWebsite: privacyPolicyWebsite ?? this.privacyPolicyWebsite,
      licenseAgreementWebsite: licenseAgreementWebsite ?? this.licenseAgreementWebsite,
      imageDataVersion: imageDataVersion ?? this.imageDataVersion,
      avoidCache: avoidCache ?? this.avoidCache,
    );
  }
  
  /// Validates this sticker pack against WhatsApp requirements.
  /// 
  /// Returns a record with validation status and detailed error information.
  ({bool isValid, List<String> errors}) validate() {
    final errors = <String>[];
    
    // Validate basic string fields
    if (identifier.isEmpty) {
      errors.add('Identifier cannot be empty');
    } else if (identifier.length > ValidationLimits.maxCharacterLimit) {
      errors.add('Identifier too long (${identifier.length} chars). '
                 'Maximum: ${ValidationLimits.maxCharacterLimit}');
    }
    
    if (name.isEmpty) {
      errors.add('Name cannot be empty');
    } else if (name.length > ValidationLimits.maxCharacterLimit) {
      errors.add('Name too long (${name.length} chars). '
                 'Maximum: ${ValidationLimits.maxCharacterLimit}');
    }
    
    if (publisher.isEmpty) {
      errors.add('Publisher cannot be empty');
    } else if (publisher.length > ValidationLimits.maxCharacterLimit) {
      errors.add('Publisher too long (${publisher.length} chars). '
                 'Maximum: ${ValidationLimits.maxCharacterLimit}');
    }
    
    // Validate tray image
    if (trayImageData.isEmpty) {
      errors.add('Tray image data cannot be empty');
    } else if (trayImageData.length > ValidationLimits.maxTrayImageFileSize) {
      final sizeKb = (trayImageData.length / 1024).toStringAsFixed(1);
      final maxSizeKb = (ValidationLimits.maxTrayImageFileSize / 1024).toStringAsFixed(0);
      errors.add('Tray image size ($sizeKb KB) exceeds maximum ($maxSizeKb KB)');
    }
    
    // Validate stickers count
    if (stickers.length < ValidationLimits.minStickersPerPack) {
      errors.add('Not enough stickers (${stickers.length}). '
                 'Minimum: ${ValidationLimits.minStickersPerPack}');
    } else if (stickers.length > ValidationLimits.maxStickersPerPack) {
      errors.add('Too many stickers (${stickers.length}). '
                 'Maximum: ${ValidationLimits.maxStickersPerPack}');
    }
    
    // Validate individual stickers
    final isAnimatedPack = isAnimated;
    for (int i = 0; i < stickers.length; i++) {
      final sticker = stickers[i];
      final stickerValidation = sticker.validate();
      
      if (!stickerValidation.isValid) {
        errors.add('Sticker ${i + 1}: ${stickerValidation.error}');
      }
      
      // Check consistency of animated vs static
      if (isAnimatedPack && !sticker.isAnimated) {
        errors.add('Sticker ${i + 1}: Animated pack contains static sticker');
      } else if (!isAnimatedPack && sticker.isAnimated) {
        errors.add('Sticker ${i + 1}: Static pack contains animated sticker');
      }
    }
    
    // Validate URLs if provided
    final urlFields = [
      ('Publisher website', publisherWebsite),
      ('Privacy policy website', privacyPolicyWebsite),
      ('License agreement website', licenseAgreementWebsite),
    ];
    
    for (final (fieldName, url) in urlFields) {
      if (url != null && url.isNotEmpty && !_isValidUrl(url)) {
        errors.add('$fieldName is not a valid URL: $url');
      }
    }
    
    // Validate email if provided
    if (publisherEmail != null && 
        publisherEmail!.isNotEmpty && 
        !_isValidEmail(publisherEmail!)) {
      errors.add('Publisher email is not valid: $publisherEmail');
    }
    
    return (isValid: errors.isEmpty, errors: errors);
  }
  
  /// Checks if a URL is valid (basic validation).
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
  
  /// Checks if an email address is valid (basic validation).
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StickerPack &&
    runtimeType == other.runtimeType &&
    identifier == other.identifier &&
    name == other.name &&
    publisher == other.publisher &&
    stickers == other.stickers;
  
  @override
  int get hashCode => Object.hash(
    identifier,
    name,
    publisher,
    stickers,
  );
  
  @override
  String toString() => 'StickerPack('
    'identifier: $identifier, '
    'name: $name, '
    'publisher: $publisher, '
    'stickers: ${stickers.length}, '
    'isAnimated: $isAnimated, '
    'totalSize: $formattedSize'
    ')';
}