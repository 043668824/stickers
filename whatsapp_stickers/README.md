# WhatsApp Stickers Flutter Plugin

A modern Flutter plugin for integrating WhatsApp stickers with full Dart 3 compatibility, using Kotlin (KTS) for Android and Swift for iOS.

## Features

✅ **Modern Dart 3 API** - Uses sealed classes, records, and pattern matching  
✅ **Full Type Safety** - Comprehensive null safety and strong typing  
✅ **Advanced Validation** - Built-in validation for all WhatsApp requirements  
✅ **Cross-Platform** - Works on both Android and iOS  
✅ **Error Handling** - Type-safe error handling with detailed error information  
✅ **Async/Await** - Modern async patterns throughout  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  whatsapp_stickers: ^1.0.0
```

## Platform Setup

### Android Setup

1. **Add Content Provider** - Add this to your `android/app/src/main/AndroidManifest.xml`:

```xml
<provider
    android:name="com.whatsapp.stickers.StickerContentProvider"
    android:authorities="${applicationId}.stickercontentprovider"
    android:enabled="true"
    android:exported="true"
    android:readPermission="com.whatsapp.sticker.READ" />
```

2. **Add Queries** - Also in your manifest:

```xml
<queries>
    <package android:name="com.whatsapp" />
    <package android:name="com.whatsapp.w4b" />
</queries>
```

3. **Update build.gradle** - In your `android/app/build.gradle`:

```groovy
android {
    compileSdkVersion 34
    
    defaultConfig {
        targetSdkVersion 34
        // ... other config
        
        def contentProviderAuthority = applicationId + ".stickercontentprovider"
        manifestPlaceholders = [contentProviderAuthority: contentProviderAuthority]
        buildConfigField("String", "CONTENT_PROVIDER_AUTHORITY", "\"${contentProviderAuthority}\"")
    }
}
```

### iOS Setup

No additional setup required for iOS! The plugin handles WhatsApp integration through URL schemes and the pasteboard.

## Usage

### Basic Example

```dart
import 'package:whatsapp_stickers/whatsapp_stickers.dart';
import 'dart:typed_data';

// Check if WhatsApp is installed
final whatsAppResult = await WhatsAppStickers.isWhatsAppInstalled();
if (whatsAppResult.isSuccess && whatsAppResult.data!) {
  print('WhatsApp is available!');
}

// Create stickers
final stickers = [
  Sticker(
    imageFileName: 'happy.webp',
    imageData: await loadImageData('assets/stickers/happy.webp'),
    emojis: ['😀', '😊'],
    accessibilityText: 'A happy smiling face',
  ),
  // Add more stickers (3-30 total)
];

// Create sticker pack
final stickerPack = StickerPack(
  identifier: 'my_awesome_pack',
  name: 'My Awesome Stickers',
  publisher: 'Your Name',
  trayImageData: await loadImageData('assets/tray_image.png'),
  stickers: stickers,
  publisherWebsite: 'https://yourwebsite.com',
);

// Validate the sticker pack
final validationResult = await WhatsAppStickers.validateStickerPack(stickerPack);
switch (validationResult) {
  case WhatsAppSuccess():
    print('✅ Sticker pack is valid!');
  case WhatsAppError(:final message, :final details):
    print('❌ Validation failed: $message');
    if (details is List<String>) {
      for (final error in details) {
        print('  • $error');
      }
    }
}

// Add to WhatsApp
final result = await WhatsAppStickers.addStickerPack(stickerPack);
switch (result) {
  case WhatsAppSuccess(:final data):
    if (data) {
      print('🎉 Sticker pack added to WhatsApp!');
    } else {
      print('❌ Failed to add sticker pack');
    }
  case WhatsAppError(:final message):
    print('❌ Error: $message');
}
```

### Advanced Usage with Pattern Matching

```dart
// Modern Dart 3 pattern matching for result handling
final result = await WhatsAppStickers.addStickerPack(stickerPack);

final message = switch (result) {
  WhatsAppSuccess(data: true) => 'Success! Sticker pack added.',
  WhatsAppSuccess(data: false) => 'Failed to add sticker pack.',
  WhatsAppError(message: final msg, code: 'whatsapp_not_installed') => 
    'Please install WhatsApp first: $msg',
  WhatsAppError(message: final msg, code: 'validation_failed') => 
    'Sticker pack is invalid: $msg',
  WhatsAppError(message: final msg) => 
    'Unexpected error: $msg',
};

print(message);
```

## Sticker Requirements

### Images
- **Format**: PNG or WebP
- **Dimensions**: 512x512 pixels exactly
- **Size**: Max 100KB for static, 500KB for animated stickers
- **Tray Image**: 96x96 pixels, PNG format, max 50KB

### Sticker Packs
- **Count**: 3-30 stickers per pack
- **Identifier**: Unique string, max 128 characters
- **Name/Publisher**: Max 128 characters each
- **Emojis**: Max 3 emojis per sticker

### Validation

The plugin provides comprehensive validation:

```dart
final stickerPack = StickerPack(/* ... */);
final validation = stickerPack.validate();

if (!validation.isValid) {
  print('Validation errors:');
  for (final error in validation.errors) {
    print('• $error');
  }
}
```

## Error Handling

The plugin uses modern Dart 3 sealed classes for type-safe error handling:

```dart
sealed class WhatsAppResult<T> {
  // Success case
  WhatsAppSuccess<T>(T data)
  
  // Error case  
  WhatsAppError<T>(String message, {String? code, Object? details})
}
```

## Contributing

Based on the official WhatsApp Stickers sample apps. See the [original repository](https://github.com/WhatsApp/stickers) for more details.

## License

This project is licensed under the same terms as the original WhatsApp stickers repository.