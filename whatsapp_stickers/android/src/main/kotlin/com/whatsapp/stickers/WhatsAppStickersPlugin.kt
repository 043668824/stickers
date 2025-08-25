package com.whatsapp.stickers

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/**
 * Modern Kotlin implementation of WhatsApp Stickers plugin for Android.
 * 
 * Uses coroutines, sealed classes, and modern Android patterns.
 */
class WhatsAppStickersPlugin: FlutterPlugin, MethodCallHandler {
    
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    companion object {
        private const val CONSUMER_WHATSAPP_PACKAGE_NAME = "com.whatsapp"
        private const val SMB_WHATSAPP_PACKAGE_NAME = "com.whatsapp.w4b"
        private const val CONTENT_PROVIDER_SUFFIX = ".provider.sticker_whitelist_check"
        private const val QUERY_PATH = "is_whitelisted"
        private const val QUERY_RESULT_COLUMN_NAME = "result"
        private const val AUTHORITY_QUERY_PARAM = "authority"
        private const val IDENTIFIER_QUERY_PARAM = "identifier"
        
        // Intent extras for adding sticker packs
        private const val EXTRA_STICKER_PACK_ID = "sticker_pack_id"
        private const val EXTRA_STICKER_PACK_AUTHORITY = "sticker_pack_authority"
        private const val EXTRA_STICKER_PACK_NAME = "sticker_pack_name"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "whatsapp_stickers")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "addStickerPack" -> {
                scope.launch {
                    addStickerPack(call, result)
                }
            }
            "isStickerPackInstalled" -> {
                scope.launch {
                    checkStickerPackInstalled(call, result)
                }
            }
            "isWhatsAppInstalled" -> {
                scope.launch {
                    checkWhatsAppInstalled(result)
                }
            }
            "validateStickerPack" -> {
                scope.launch {
                    validateStickerPack(call, result)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private suspend fun addStickerPack(call: MethodCall, result: Result) = withContext(Dispatchers.IO) {
        try {
            val identifier = call.argument<String>("identifier") 
                ?: return@withContext result.error("MISSING_IDENTIFIER", "Sticker pack identifier is required", null)
            val stickerPackName = call.argument<String>("name") 
                ?: return@withContext result.error("MISSING_NAME", "Sticker pack name is required", null)
            
            // Check if WhatsApp is installed
            val whatsAppStatus = getWhatsAppInstallationStatus()
            if (!whatsAppStatus.hasAnyWhatsApp) {
                return@withContext result.error(
                    "WHATSAPP_NOT_INSTALLED", 
                    "WhatsApp is not installed on this device", 
                    null
                )
            }
            
            // Launch intent to add pack to WhatsApp
            val success = launchIntentToAddPack(identifier, stickerPackName)
            
            withContext(Dispatchers.Main) {
                result.success(success)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("ADD_PACK_ERROR", "Failed to add sticker pack: ${e.message}", e.toString())
            }
        }
    }

    private suspend fun checkStickerPackInstalled(call: MethodCall, result: Result) = withContext(Dispatchers.IO) {
        try {
            val identifier = call.argument<String>("identifier") 
                ?: return@withContext result.error("MISSING_IDENTIFIER", "Sticker pack identifier is required", null)
            
            val isInstalled = isStickerPackWhitelisted(identifier)
            
            withContext(Dispatchers.Main) {
                result.success(isInstalled)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("CHECK_INSTALL_ERROR", "Failed to check installation status: ${e.message}", e.toString())
            }
        }
    }

    private suspend fun checkWhatsAppInstalled(result: Result) = withContext(Dispatchers.IO) {
        try {
            val status = getWhatsAppInstallationStatus()
            
            withContext(Dispatchers.Main) {
                result.success(status.hasAnyWhatsApp)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("CHECK_WHATSAPP_ERROR", "Failed to check WhatsApp installation: ${e.message}", e.toString())
            }
        }
    }

    private suspend fun validateStickerPack(call: MethodCall, result: Result) = withContext(Dispatchers.IO) {
        try {
            // Validation is primarily done on the Dart side
            // Here we can do additional platform-specific validation if needed
            
            withContext(Dispatchers.Main) {
                result.success(true)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("VALIDATION_ERROR", "Failed to validate sticker pack: ${e.message}", e.toString())
            }
        }
    }

    /**
     * Data class representing WhatsApp installation status using modern Kotlin patterns.
     */
    private data class WhatsAppInstallationStatus(
        val hasConsumerWhatsApp: Boolean,
        val hasSmbWhatsApp: Boolean
    ) {
        val hasAnyWhatsApp: Boolean
            get() = hasConsumerWhatsApp || hasSmbWhatsApp
    }

    private fun getWhatsAppInstallationStatus(): WhatsAppInstallationStatus {
        val packageManager = context.packageManager
        return WhatsAppInstallationStatus(
            hasConsumerWhatsApp = isPackageInstalled(CONSUMER_WHATSAPP_PACKAGE_NAME, packageManager),
            hasSmbWhatsApp = isPackageInstalled(SMB_WHATSAPP_PACKAGE_NAME, packageManager)
        )
    }

    private fun isPackageInstalled(packageName: String, packageManager: PackageManager): Boolean {
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            applicationInfo.enabled
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun isStickerPackWhitelisted(identifier: String): Boolean {
        val status = getWhatsAppInstallationStatus()
        
        var isWhitelistedInConsumer = false
        var isWhitelistedInSmb = false
        
        if (status.hasConsumerWhatsApp) {
            isWhitelistedInConsumer = isWhitelistedFromProvider(identifier, CONSUMER_WHATSAPP_PACKAGE_NAME)
        }
        
        if (status.hasSmbWhatsApp) {
            isWhitelistedInSmb = isWhitelistedFromProvider(identifier, SMB_WHATSAPP_PACKAGE_NAME)
        }
        
        return isWhitelistedInConsumer || isWhitelistedInSmb
    }

    private fun isWhitelistedFromProvider(identifier: String, whatsappPackageName: String): Boolean {
        return try {
            val packageManager = context.packageManager
            val providerInfo = packageManager.resolveContentProvider(
                "$whatsappPackageName$CONTENT_PROVIDER_SUFFIX", 
                PackageManager.GET_META_DATA
            ) ?: return false

            // Query the WhatsApp content provider to check whitelist status
            val authority = providerInfo.authority
            val providerAuthority = context.packageName + ".stickercontentprovider"
            
            val uri = Uri.Builder()
                .scheme("content")
                .authority(authority)
                .appendPath(QUERY_PATH)
                .appendQueryParameter(AUTHORITY_QUERY_PARAM, providerAuthority)
                .appendQueryParameter(IDENTIFIER_QUERY_PARAM, identifier)
                .build()

            val cursor: Cursor? = context.contentResolver.query(uri, null, null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val whiteListResult = it.getInt(it.getColumnIndexOrThrow(QUERY_RESULT_COLUMN_NAME))
                    return whiteListResult == 1
                }
            }
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun launchIntentToAddPack(identifier: String, stickerPackName: String): Boolean {
        return try {
            val intent = createAddStickerPackIntent(identifier, stickerPackName)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun createAddStickerPackIntent(identifier: String, stickerPackName: String): Intent {
        val intent = Intent()
        intent.action = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
        intent.putExtra(EXTRA_STICKER_PACK_ID, identifier)
        intent.putExtra(EXTRA_STICKER_PACK_AUTHORITY, context.packageName + ".stickercontentprovider")
        intent.putExtra(EXTRA_STICKER_PACK_NAME, stickerPackName)
        return intent
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}