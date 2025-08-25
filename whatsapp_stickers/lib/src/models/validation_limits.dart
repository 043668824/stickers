/// Validation limits and constraints for WhatsApp stickers.
/// 
/// These limits are based on WhatsApp's official requirements and should not
/// be modified as they reflect platform constraints.
class ValidationLimits {
  /// Maximum file size for static stickers in bytes (100KB).
  static const int maxStaticStickerFileSize = 100 * 1024;
  
  /// Maximum file size for animated stickers in bytes (500KB).
  static const int maxAnimatedStickerFileSize = 500 * 1024;
  
  /// Maximum file size for tray images in bytes (50KB).
  static const int maxTrayImageFileSize = 50 * 1024;
  
  /// Required dimensions for sticker images (512x512 pixels).
  static const (int width, int height) stickerDimensions = (512, 512);
  
  /// Required dimensions for tray images (96x96 pixels).
  static const (int width, int height) trayImageDimensions = (96, 96);
  
  /// Minimum number of stickers per pack.
  static const int minStickersPerPack = 3;
  
  /// Maximum number of stickers per pack.
  static const int maxStickersPerPack = 30;
  
  /// Maximum character limit for names, publishers, and identifiers.
  static const int maxCharacterLimit = 128;
  
  /// Maximum number of emojis per sticker.
  static const int maxEmojisPerSticker = 3;
  
  /// Maximum accessibility text length for static stickers.
  static const int maxStaticAccessibilityTextLength = 125;
  
  /// Maximum accessibility text length for animated stickers.
  static const int maxAnimatedAccessibilityTextLength = 255;
  
  /// Minimum frame duration for animated stickers in milliseconds.
  static const int minAnimatedFrameDurationMs = 8;
  
  /// Maximum total animation duration in milliseconds (10 seconds).
  static const int maxAnimatedTotalDurationMs = 10000;
  
  /// Supported image formats for stickers.
  static const Set<String> supportedImageFormats = {'png', 'webp'};
  
  /// Supported image format for tray images.
  static const Set<String> supportedTrayImageFormats = {'png'};
}