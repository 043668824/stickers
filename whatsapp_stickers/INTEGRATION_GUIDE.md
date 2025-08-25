# Integration Guide for WhatsApp Stickers Flutter Plugin

This guide provides step-by-step instructions for integrating the WhatsApp Stickers Flutter plugin into your app.

## Quick Setup

### 1. Add Dependency

```yaml
dependencies:
  whatsapp_stickers: ^1.0.0
```

### 2. Android Configuration

#### a. Create ContentProvider

Create `android/app/src/main/kotlin/[your/package]/StickerContentProvider.kt`:

```kotlin
package com.yourcompany.yourapp

import com.whatsapp.stickers.BaseStickerContentProvider
import com.whatsapp.stickers.StickerPackData
import com.whatsapp.stickers.StickerData

class StickerContentProvider : BaseStickerContentProvider() {
    
    override fun getStickerPackList(): List<StickerPackData> {
        // Return your sticker packs here
        // This can be loaded from assets, network, or generated dynamically
        return listOf(
            StickerPackData(
                identifier = "pack_001",
                name = "My Sticker Pack",
                publisher = "Your Name",
                trayImageFile = "tray_image.png",
                stickers = listOf(
                    StickerData(
                        imageFile = "sticker1.webp",
                        emojis = listOf("😀", "👋"),
                        accessibilityText = "Happy waving face"
                    ),
                    // Add more stickers...
                )
            )
        )
    }
}
```

#### b. Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Your existing activities -->
    
    <!-- Add the ContentProvider -->
    <provider
        android:name=".StickerContentProvider"
        android:authorities="${applicationId}.stickercontentprovider"
        android:enabled="true"
        android:exported="true"
        android:readPermission="com.whatsapp.sticker.READ" />
</application>

<!-- Add outside <application> tag -->
<queries>
    <package android:name="com.whatsapp" />
    <package android:name="com.whatsapp.w4b" />
</queries>
```

#### c. Update build.gradle

In `android/app/build.gradle`:

```groovy
android {
    compileSdkVersion 34
    
    defaultConfig {
        // ... existing config
        
        // Add ContentProvider authority configuration
        def contentProviderAuthority = applicationId + ".stickercontentprovider"
        manifestPlaceholders = [contentProviderAuthority: contentProviderAuthority]
        buildConfigField("String", "CONTENT_PROVIDER_AUTHORITY", "\"${contentProviderAuthority}\"")
    }
}
```

### 3. iOS Configuration

No additional setup required for iOS! The plugin works out of the box.

### 4. Usage in Flutter Code

```dart
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

class StickerPackService {
  
  Future<bool> addStickerPackToWhatsApp() async {
    // Check if WhatsApp is available
    final whatsAppCheck = await WhatsAppStickers.isWhatsAppInstalled();
    if (whatsAppCheck.isError || !whatsAppCheck.data!) {
      print('WhatsApp is not installed');
      return false;
    }
    
    // Load your sticker assets
    final stickers = await _loadStickers();
    final trayImage = await _loadTrayImage();
    
    // Create sticker pack
    final stickerPack = StickerPack(
      identifier: 'unique_pack_id',
      name: 'My Sticker Pack',
      publisher: 'Your Name',
      trayImageData: trayImage,
      stickers: stickers,
    );
    
    // Validate before adding
    final validation = await WhatsAppStickers.validateStickerPack(stickerPack);
    if (validation.isError) {
      print('Validation failed: ${validation.errorMessage}');
      return false;
    }
    
    // Add to WhatsApp
    final result = await WhatsAppStickers.addStickerPack(stickerPack);
    return result.isSuccess && result.data!;
  }
  
  Future<List<Sticker>> _loadStickers() async {
    // Load your sticker images from assets or network
    // Return list of Sticker objects
  }
  
  Future<Uint8List> _loadTrayImage() async {
    // Load your tray image (96x96 PNG)
    // Return image data as Uint8List
  }
}
```

## Best Practices

### 1. Asset Organization
```
assets/
  stickers/
    pack1/
      tray_image.png      # 96x96 PNG, <50KB
      sticker1.webp       # 512x512, <100KB static/<500KB animated
      sticker2.webp
      ...
    pack2/
      ...
```

### 2. Error Handling
```dart
Future<void> addStickerPack(StickerPack pack) async {
  final result = await WhatsAppStickers.addStickerPack(pack);
  
  switch (result) {
    case WhatsAppSuccess(:final data):
      if (data) {
        showSuccessMessage('Sticker pack added successfully!');
      } else {
        showErrorMessage('Failed to add sticker pack');
      }
      
    case WhatsAppError(:final message, :final code):
      switch (code) {
        case 'whatsapp_not_installed':
          showInstallWhatsAppDialog();
        case 'validation_failed':
          showValidationErrorDialog(message);
        default:
          showErrorMessage('Error: $message');
      }
  }
}
```

### 3. Validation Before Adding
```dart
Future<bool> validateAndAdd(StickerPack pack) async {
  // Client-side validation
  final validation = pack.validate();
  if (!validation.isValid) {
    for (final error in validation.errors) {
      print('Validation error: $error');
    }
    return false;
  }
  
  // Platform validation
  final platformValidation = await WhatsAppStickers.validateStickerPack(pack);
  if (platformValidation.isError) {
    print('Platform validation failed: ${platformValidation.errorMessage}');
    return false;
  }
  
  // Add to WhatsApp
  final result = await WhatsAppStickers.addStickerPack(pack);
  return result.isSuccess && result.data!;
}
```

## Troubleshooting

### Common Issues

1. **"ContentProvider not found"** (Android)
   - Ensure you've added the ContentProvider to AndroidManifest.xml
   - Check that the authority matches your application ID

2. **"WhatsApp not opening"** (iOS)  
   - Verify WhatsApp is installed on the device
   - Check that your bundle identifier doesn't contain the default template ID

3. **"Validation failed"**
   - Check image dimensions (512x512 for stickers, 96x96 for tray)
   - Verify file sizes are within limits
   - Ensure you have 3-30 stickers per pack

### Debug Tips

```dart
// Enable detailed logging
final pack = StickerPack(/* ... */);
final validation = pack.validate();

print('Pack validation: ${validation.isValid}');
if (!validation.isValid) {
  for (final error in validation.errors) {
    print('• $error');
  }
}

print('Pack info:');
print('• Total size: ${pack.formattedSize}');
print('• Sticker count: ${pack.stickers.length}');
print('• Is animated: ${pack.isAnimated}');
```

## Migration from Native Apps

If you have an existing Android or iOS sticker app, here's how to migrate:

### From Android App
1. Copy your `contents.json` file
2. Use the existing ContentProvider structure
3. Replace native UI with Flutter UI
4. Use this plugin for WhatsApp integration

### From iOS App  
1. Copy your sticker assets
2. Replace native Swift code with Flutter + this plugin
3. Keep the same pasteboard-based integration approach

The plugin handles all the platform-specific details while providing a clean, modern Dart API.