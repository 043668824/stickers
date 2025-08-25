/// Base exception for WhatsApp stickers plugin.
/// 
/// Uses modern Dart 3 sealed classes for type-safe exception handling.
sealed class WhatsAppStickersException implements Exception {
  const WhatsAppStickersException(this.message, {this.code});
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'WhatsAppStickersException($code): $message';
}

/// Exception thrown when WhatsApp is not installed on the device.
final class WhatsAppNotInstalledException extends WhatsAppStickersException {
  const WhatsAppNotInstalledException([String? message]) 
    : super(message ?? 'WhatsApp is not installed on this device', code: 'whatsapp_not_installed');
}

/// Exception thrown when sticker pack validation fails.
final class StickerPackValidationException extends WhatsAppStickersException {
  const StickerPackValidationException(String message, {this.validationErrors}) 
    : super(message, code: 'validation_failed');
  
  final List<String>? validationErrors;
  
  @override
  String toString() {
    if (validationErrors?.isNotEmpty == true) {
      return 'StickerPackValidationException: $message\n'
             'Validation errors:\n${validationErrors!.map((e) => '  • $e').join('\n')}';
    }
    return super.toString();
  }
}

/// Exception thrown when adding a sticker pack to WhatsApp fails.
final class AddStickerPackException extends WhatsAppStickersException {
  const AddStickerPackException(String message) 
    : super(message, code: 'add_pack_failed');
}

/// Exception thrown when checking sticker pack whitelist status fails.
final class WhitelistCheckException extends WhatsAppStickersException {
  const WhitelistCheckException(String message) 
    : super(message, code: 'whitelist_check_failed');
}

/// Exception thrown for platform-specific errors.
final class PlatformException extends WhatsAppStickersException {
  const PlatformException(String message, {String? platformCode}) 
    : super(message, code: platformCode ?? 'platform_error');
}

/// Exception thrown when an image format is not supported.
final class UnsupportedImageFormatException extends WhatsAppStickersException {
  const UnsupportedImageFormatException(String format) 
    : super('Unsupported image format: $format', code: 'unsupported_format');
}

/// Exception thrown when an image is too large.
final class ImageTooLargeException extends WhatsAppStickersException {
  ImageTooLargeException(int actualSize, int maxSize) 
    : super('Image size (${(actualSize / 1024).toStringAsFixed(1)} KB) '
            'exceeds maximum allowed size (${(maxSize / 1024).toStringAsFixed(0)} KB)', 
            code: 'image_too_large');
}

/// Exception thrown when image dimensions are incorrect.
final class IncorrectImageDimensionsException extends WhatsAppStickersException {
  const IncorrectImageDimensionsException(int width, int height, int expectedWidth, int expectedHeight) 
    : super('Image dimensions (${width}x${height}) do not match required dimensions (${expectedWidth}x${expectedHeight})', 
            code: 'incorrect_dimensions');
}