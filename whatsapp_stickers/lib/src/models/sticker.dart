import 'dart:typed_data';
import 'validation_limits.dart';

/// Represents an individual sticker within a sticker pack.
/// 
/// Uses modern Dart 3 features including records for emojis and validation.
class Sticker {
  /// Creates a new sticker with the provided image data and metadata.
  /// 
  /// The [imageFileName] should include the file extension (png or webp).
  /// [emojis] can contain up to 3 emoji characters that represent this sticker.
  /// [accessibilityText] provides description for accessibility features.
  const Sticker({
    required this.imageFileName,
    required this.imageData,
    required this.emojis,
    this.accessibilityText,
  });

  /// The filename of the sticker image (including extension).
  final String imageFileName;
  
  /// The raw image data as bytes.
  final Uint8List imageData;
  
  /// List of emoji characters associated with this sticker (max 3).
  final List<String> emojis;
  
  /// Optional accessibility text describing the sticker.
  final String? accessibilityText;
  
  /// The file extension of the image (png or webp).
  String get fileExtension => 
    imageFileName.split('.').lastOrNull?.toLowerCase() ?? '';
  
  /// Whether this sticker uses an animated format (webp).
  bool get isAnimated => fileExtension == 'webp';
  
  /// The size of the image data in bytes.
  int get sizeInBytes => imageData.length;
  
  /// Creates a copy of this sticker with updated properties.
  Sticker copyWith({
    String? imageFileName,
    Uint8List? imageData,
    List<String>? emojis,
    String? accessibilityText,
  }) {
    return Sticker(
      imageFileName: imageFileName ?? this.imageFileName,
      imageData: imageData ?? this.imageData,
      emojis: emojis ?? this.emojis,
      accessibilityText: accessibilityText ?? this.accessibilityText,
    );
  }
  
  /// Validates this sticker against WhatsApp requirements.
  /// 
  /// Returns a record with validation status and error message if invalid.
  ({bool isValid, String? error}) validate() {
    // Check file extension
    if (!ValidationLimits.supportedImageFormats.contains(fileExtension)) {
      return (
        isValid: false, 
        error: 'Unsupported image format: $fileExtension. '
               'Supported formats: ${ValidationLimits.supportedImageFormats.join(', ')}'
      );
    }
    
    // Check file size
    final maxSize = isAnimated 
      ? ValidationLimits.maxAnimatedStickerFileSize
      : ValidationLimits.maxStaticStickerFileSize;
    
    if (sizeInBytes > maxSize) {
      final sizeKb = (sizeInBytes / 1024).toStringAsFixed(1);
      final maxSizeKb = (maxSize / 1024).toStringAsFixed(0);
      return (
        isValid: false,
        error: 'Image size ($sizeKb KB) exceeds maximum allowed size ($maxSizeKb KB)'
      );
    }
    
    // Check emojis count
    if (emojis.length > ValidationLimits.maxEmojisPerSticker) {
      return (
        isValid: false,
        error: 'Too many emojis (${emojis.length}). '
               'Maximum allowed: ${ValidationLimits.maxEmojisPerSticker}'
      );
    }
    
    // Check accessibility text length
    if (accessibilityText != null) {
      final maxLength = isAnimated 
        ? ValidationLimits.maxAnimatedAccessibilityTextLength
        : ValidationLimits.maxStaticAccessibilityTextLength;
      
      if (accessibilityText!.length > maxLength) {
        return (
          isValid: false,
          error: 'Accessibility text too long (${accessibilityText!.length} characters). '
                 'Maximum allowed: $maxLength'
        );
      }
    }
    
    return (isValid: true, error: null);
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Sticker &&
    runtimeType == other.runtimeType &&
    imageFileName == other.imageFileName &&
    emojis == other.emojis &&
    accessibilityText == other.accessibilityText;
  
  @override
  int get hashCode => Object.hash(
    imageFileName,
    emojis,
    accessibilityText,
  );
  
  @override
  String toString() => 'Sticker('
    'imageFileName: $imageFileName, '
    'emojis: $emojis, '
    'accessibilityText: $accessibilityText, '
    'sizeInBytes: $sizeInBytes'
    ')';
}