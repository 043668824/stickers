package com.whatsapp.stickers

import android.content.*
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.text.TextUtils
import androidx.annotation.Nullable

/**
 * Helper class for creating a ContentProvider for WhatsApp sticker integration.
 * 
 * Apps using this plugin should extend this class and provide sticker pack data.
 * This is required for Android apps to work with WhatsApp.
 */
abstract class BaseStickerContentProvider : ContentProvider() {
    
    companion object {
        // Column names for metadata query
        const val STICKER_PACK_IDENTIFIER_IN_QUERY = "sticker_pack_identifier"
        const val STICKER_PACK_NAME_IN_QUERY = "sticker_pack_name"
        const val STICKER_PACK_PUBLISHER_IN_QUERY = "sticker_pack_publisher"
        const val STICKER_PACK_ICON_IN_QUERY = "sticker_pack_icon"
        const val ANDROID_APP_DOWNLOAD_LINK_IN_QUERY = "android_app_download_link"
        const val IOS_APP_DOWNLOAD_LINK_IN_QUERY = "ios_app_download_link"
        const val PUBLISHER_EMAIL = "publisher_email"
        const val PUBLISHER_WEBSITE = "publisher_website"
        const val PRIVACY_POLICY_WEBSITE = "privacy_policy_website"
        const val LICENSE_AGREEMENT_WEBSITE = "license_agreement_website"
        const val IMAGE_DATA_VERSION = "image_data_version"
        const val AVOID_CACHE = "whatsapp_will_not_cache_stickers"
        const val ANIMATED_STICKER_PACK = "animated_sticker_pack"
        
        // Column names for stickers query
        const val STICKER_FILE_NAME_IN_QUERY = "sticker_file_name"
        const val STICKER_EMOJI_IN_QUERY = "sticker_emoji"
        const val STICKER_ACCESSIBILITY_TEXT_IN_QUERY = "sticker_accessibility_text"
        
        // URI matcher codes
        private const val METADATA = 100
        private const val METADATA_CODE_FOR_SINGLE_PACK = 200
        private const val STICKERS = 300
        private const val STICKERS_ASSET = 400
        
        // Path segments
        private const val METADATA_PATH = "metadata"
        private const val STICKERS_PATH = "stickers"
        private const val STICKERS_ASSET_PATH = "stickers_asset"
    }
    
    private val uriMatcher = UriMatcher(UriMatcher.NO_MATCH)
    
    /**
     * Subclasses must implement this to provide their sticker pack data.
     */
    abstract fun getStickerPackList(): List<StickerPackData>
    
    override fun onCreate(): Boolean {
        val authority = context!!.packageName + ".stickercontentprovider"
        
        uriMatcher.addURI(authority, METADATA_PATH, METADATA)
        uriMatcher.addURI(authority, "$METADATA_PATH/*", METADATA_CODE_FOR_SINGLE_PACK)
        uriMatcher.addURI(authority, "$STICKERS_PATH/*", STICKERS)
        uriMatcher.addURI(authority, "$STICKERS_ASSET_PATH/*/*", STICKERS_ASSET)
        
        return true
    }
    
    override fun query(
        uri: Uri, 
        projection: Array<String>?, 
        selection: String?, 
        selectionArgs: Array<String>?, 
        sortOrder: String?
    ): Cursor? {
        val code = uriMatcher.match(uri)
        return when (code) {
            METADATA -> getPackForAllStickerPacks(uri)
            METADATA_CODE_FOR_SINGLE_PACK -> getCursorForSingleStickerPack(uri)
            STICKERS -> getStickersForAStickerPack(uri)
            else -> throw IllegalArgumentException("Unknown URI: $uri")
        }
    }
    
    private fun getPackForAllStickerPacks(uri: Uri): Cursor {
        return getStickerPackInfo(uri, getStickerPackList())
    }
    
    private fun getCursorForSingleStickerPack(uri: Uri): Cursor {
        val identifier = uri.lastPathSegment
        val stickerPackList = getStickerPackList()
        val stickerPack = stickerPackList.find { it.identifier == identifier }
        return if (stickerPack != null) {
            getStickerPackInfo(uri, listOf(stickerPack))
        } else {
            getStickerPackInfo(uri, emptyList())
        }
    }
    
    private fun getStickerPackInfo(uri: Uri, stickerPackList: List<StickerPackData>): Cursor {
        val cursor = MatrixCursor(arrayOf(
            STICKER_PACK_IDENTIFIER_IN_QUERY,
            STICKER_PACK_NAME_IN_QUERY,
            STICKER_PACK_PUBLISHER_IN_QUERY,
            STICKER_PACK_ICON_IN_QUERY,
            ANDROID_APP_DOWNLOAD_LINK_IN_QUERY,
            IOS_APP_DOWNLOAD_LINK_IN_QUERY,
            PUBLISHER_EMAIL,
            PUBLISHER_WEBSITE,
            PRIVACY_POLICY_WEBSITE,
            LICENSE_AGREEMENT_WEBSITE,
            IMAGE_DATA_VERSION,
            AVOID_CACHE,
            ANIMATED_STICKER_PACK
        ))
        
        for (stickerPack in stickerPackList) {
            val builder = cursor.newRow()
            builder.add(stickerPack.identifier)
            builder.add(stickerPack.name)
            builder.add(stickerPack.publisher)
            builder.add(stickerPack.trayImageFile)
            builder.add(stickerPack.androidPlayStoreLink)
            builder.add(stickerPack.iosAppStoreLink)
            builder.add(stickerPack.publisherEmail)
            builder.add(stickerPack.publisherWebsite)
            builder.add(stickerPack.privacyPolicyWebsite)
            builder.add(stickerPack.licenseAgreementWebsite)
            builder.add(stickerPack.imageDataVersion)
            builder.add(if (stickerPack.avoidCache) 1 else 0)
            builder.add(if (stickerPack.animatedStickerPack) 1 else 0)
        }
        
        cursor.setNotificationUri(context!!.contentResolver, uri)
        return cursor
    }
    
    private fun getStickersForAStickerPack(uri: Uri): Cursor {
        val identifier = uri.lastPathSegment
        val cursor = MatrixCursor(arrayOf(
            STICKER_FILE_NAME_IN_QUERY,
            STICKER_EMOJI_IN_QUERY,
            STICKER_ACCESSIBILITY_TEXT_IN_QUERY
        ))
        
        val stickerPack = getStickerPackList().find { it.identifier == identifier }
        stickerPack?.stickers?.forEach { sticker ->
            val builder = cursor.newRow()
            builder.add(sticker.imageFile)
            builder.add(TextUtils.join(",", sticker.emojis))
            builder.add(sticker.accessibilityText)
        }
        
        cursor.setNotificationUri(context!!.contentResolver, uri)
        return cursor
    }
    
    override fun getType(uri: Uri): String? = null
    
    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        throw UnsupportedOperationException("Not supported")
    }
    
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int {
        throw UnsupportedOperationException("Not supported")
    }
    
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int {
        throw UnsupportedOperationException("Not supported")
    }
}

/**
 * Data classes for sticker pack information.
 */
data class StickerPackData(
    val identifier: String,
    val name: String,
    val publisher: String,
    val trayImageFile: String,
    val publisherEmail: String = "",
    val publisherWebsite: String = "",
    val privacyPolicyWebsite: String = "",
    val licenseAgreementWebsite: String = "",
    val androidPlayStoreLink: String = "",
    val iosAppStoreLink: String = "",
    val imageDataVersion: String = "1",
    val avoidCache: Boolean = false,
    val animatedStickerPack: Boolean = false,
    val stickers: List<StickerData>
)

data class StickerData(
    val imageFile: String,
    val emojis: List<String>,
    val accessibilityText: String = ""
)