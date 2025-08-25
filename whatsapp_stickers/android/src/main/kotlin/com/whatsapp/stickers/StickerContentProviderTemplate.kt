package com.yourcompany.yourapp

import com.whatsapp.stickers.BaseStickerContentProvider
import com.whatsapp.stickers.StickerPackData
import com.whatsapp.stickers.StickerData

/**
 * Example ContentProvider implementation for WhatsApp stickers.
 * 
 * Copy this file to your Android app and modify the package name and sticker data.
 * This is required for the WhatsApp Stickers plugin to work on Android.
 */
class StickerContentProvider : BaseStickerContentProvider() {
    
    override fun getStickerPackList(): List<StickerPackData> {
        // TODO: Replace this with your actual sticker pack data
        // You can load this from assets, network, or generate dynamically
        
        return listOf(
            StickerPackData(
                identifier = "demo_pack_001",
                name = "Demo Sticker Pack",
                publisher = "Your Company",
                trayImageFile = "tray_demo.png",
                publisherWebsite = "https://yourcompany.com",
                publisherEmail = "contact@yourcompany.com",
                privacyPolicyWebsite = "https://yourcompany.com/privacy",
                licenseAgreementWebsite = "https://yourcompany.com/license",
                stickers = listOf(
                    StickerData(
                        imageFile = "demo_sticker_1.webp",
                        emojis = listOf("😀", "👋"),
                        accessibilityText = "A happy face waving hello"
                    ),
                    StickerData(
                        imageFile = "demo_sticker_2.webp", 
                        emojis = listOf("❤️", "😍"),
                        accessibilityText = "A heart with loving eyes"
                    ),
                    StickerData(
                        imageFile = "demo_sticker_3.webp",
                        emojis = listOf("🎉", "✨"),
                        accessibilityText = "Celebration with sparkles"
                    ),
                    // Add more stickers here (3-30 total required)
                )
            ),
            // Add more sticker packs here if needed
        )
    }
}