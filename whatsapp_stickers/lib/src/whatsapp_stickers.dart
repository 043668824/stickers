import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/models.dart';
import 'exceptions/exceptions.dart';

/// The interface that implementations of whatsapp_stickers must implement.
abstract class WhatsAppStickersPlatform extends PlatformInterface {
  WhatsAppStickersPlatform() : super(token: _token);

  static final Object _token = Object();

  static WhatsAppStickersPlatform _instance = MethodChannelWhatsAppStickers();

  /// The default instance of [WhatsAppStickersPlatform] to use.
  static WhatsAppStickersPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WhatsAppStickersPlatform] when
  /// they register themselves.
  static set instance(WhatsAppStickersPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Adds a sticker pack to WhatsApp.
  Future<WhatsAppResult<bool>> addStickerPack(StickerPack stickerPack);

  /// Checks if a sticker pack is already added to WhatsApp.
  Future<WhatsAppResult<bool>> isStickerPackInstalled(String identifier);

  /// Checks if WhatsApp is installed on the device.
  Future<WhatsAppResult<bool>> isWhatsAppInstalled();

  /// Validates a sticker pack without adding it to WhatsApp.
  Future<WhatsAppResult<bool>> validateStickerPack(StickerPack stickerPack);
}

/// Method channel implementation of [WhatsAppStickersPlatform].
class MethodChannelWhatsAppStickers extends WhatsAppStickersPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _methodChannel = MethodChannel('whatsapp_stickers');

  @override
  Future<WhatsAppResult<bool>> addStickerPack(StickerPack stickerPack) async {
    try {
      // Validate before sending to platform
      final validation = stickerPack.validate();
      if (!validation.isValid) {
        return WhatsAppError(
          'Sticker pack validation failed',
          code: 'validation_failed',
          details: validation.errors,
        );
      }

      final result = await _methodChannel.invokeMethod<bool>('addStickerPack', {
        'identifier': stickerPack.identifier,
        'name': stickerPack.name,
        'publisher': stickerPack.publisher,
        'trayImageData': stickerPack.trayImageData,
        'stickers': stickerPack.stickers.map((sticker) => {
          'imageFileName': sticker.imageFileName,
          'imageData': sticker.imageData,
          'emojis': sticker.emojis,
          'accessibilityText': sticker.accessibilityText,
        }).toList(),
        'publisherEmail': stickerPack.publisherEmail,
        'publisherWebsite': stickerPack.publisherWebsite,
        'privacyPolicyWebsite': stickerPack.privacyPolicyWebsite,
        'licenseAgreementWebsite': stickerPack.licenseAgreementWebsite,
        'imageDataVersion': stickerPack.imageDataVersion,
        'avoidCache': stickerPack.avoidCache,
      });

      return WhatsAppSuccess(result ?? false);
    } on PlatformException catch (e) {
      return WhatsAppError(
        e.message ?? 'Failed to add sticker pack',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      return WhatsAppError(
        'Unexpected error: $e',
        code: 'unexpected_error',
        details: e,
      );
    }
  }

  @override
  Future<WhatsAppResult<bool>> isStickerPackInstalled(String identifier) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isStickerPackInstalled', {
        'identifier': identifier,
      });

      return WhatsAppSuccess(result ?? false);
    } on PlatformException catch (e) {
      return WhatsAppError(
        e.message ?? 'Failed to check sticker pack status',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      return WhatsAppError(
        'Unexpected error: $e',
        code: 'unexpected_error',
        details: e,
      );
    }
  }

  @override
  Future<WhatsAppResult<bool>> isWhatsAppInstalled() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isWhatsAppInstalled');
      return WhatsAppSuccess(result ?? false);
    } on PlatformException catch (e) {
      return WhatsAppError(
        e.message ?? 'Failed to check WhatsApp installation',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      return WhatsAppError(
        'Unexpected error: $e',
        code: 'unexpected_error',
        details: e,
      );
    }
  }

  @override
  Future<WhatsAppResult<bool>> validateStickerPack(StickerPack stickerPack) async {
    try {
      final validation = stickerPack.validate();
      if (!validation.isValid) {
        return WhatsAppError(
          'Sticker pack validation failed',
          code: 'validation_failed',
          details: validation.errors,
        );
      }

      // Additional platform-specific validation can be done here
      final result = await _methodChannel.invokeMethod<bool>('validateStickerPack', {
        'identifier': stickerPack.identifier,
        'name': stickerPack.name,
        'publisher': stickerPack.publisher,
        'trayImageData': stickerPack.trayImageData,
        'stickers': stickerPack.stickers.map((sticker) => {
          'imageFileName': sticker.imageFileName,
          'imageData': sticker.imageData,
          'emojis': sticker.emojis,
          'accessibilityText': sticker.accessibilityText,
        }).toList(),
      });

      return WhatsAppSuccess(result ?? true);
    } on PlatformException catch (e) {
      return WhatsAppError(
        e.message ?? 'Failed to validate sticker pack',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      return WhatsAppError(
        'Unexpected error: $e',
        code: 'unexpected_error',
        details: e,
      );
    }
  }
}

/// Main class for the WhatsApp Stickers plugin.
/// 
/// Provides a modern Dart 3 API for integrating with WhatsApp stickers.
class WhatsAppStickers {
  /// Private constructor to prevent instantiation.
  WhatsAppStickers._();

  static WhatsAppStickersPlatform get _platform => WhatsAppStickersPlatform.instance;

  /// Adds a sticker pack to WhatsApp.
  /// 
  /// Returns a [WhatsAppResult] indicating success or failure.
  /// The sticker pack will be validated before being sent to WhatsApp.
  /// 
  /// Example:
  /// ```dart
  /// final result = await WhatsAppStickers.addStickerPack(stickerPack);
  /// switch (result) {
  ///   case WhatsAppSuccess(:final data):
  ///     print('Sticker pack added successfully: $data');
  ///   case WhatsAppError(:final message):
  ///     print('Failed to add sticker pack: $message');
  /// }
  /// ```
  static Future<WhatsAppResult<bool>> addStickerPack(StickerPack stickerPack) {
    return _platform.addStickerPack(stickerPack);
  }

  /// Checks if a sticker pack is already installed in WhatsApp.
  /// 
  /// Returns a [WhatsAppResult] with true if the pack is installed, false otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final result = await WhatsAppStickers.isStickerPackInstalled('my_pack_id');
  /// if (result.isSuccess && result.data == true) {
  ///   print('Sticker pack is already installed');
  /// }
  /// ```
  static Future<WhatsAppResult<bool>> isStickerPackInstalled(String identifier) {
    return _platform.isStickerPackInstalled(identifier);
  }

  /// Checks if WhatsApp is installed on the device.
  /// 
  /// Returns a [WhatsAppResult] with true if WhatsApp is available, false otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final result = await WhatsAppStickers.isWhatsAppInstalled();
  /// if (result.isSuccess && result.data == true) {
  ///   // WhatsApp is available, safe to add sticker packs
  /// }
  /// ```
  static Future<WhatsAppResult<bool>> isWhatsAppInstalled() {
    return _platform.isWhatsAppInstalled();
  }

  /// Validates a sticker pack without adding it to WhatsApp.
  /// 
  /// This is useful for checking if a sticker pack meets WhatsApp's requirements
  /// before attempting to add it.
  /// 
  /// Returns a [WhatsAppResult] with true if valid, false with error details if invalid.
  /// 
  /// Example:
  /// ```dart
  /// final result = await WhatsAppStickers.validateStickerPack(stickerPack);
  /// if (result.isError) {
  ///   print('Validation failed: ${result.errorMessage}');
  /// }
  /// ```
  static Future<WhatsAppResult<bool>> validateStickerPack(StickerPack stickerPack) {
    return _platform.validateStickerPack(stickerPack);
  }
}