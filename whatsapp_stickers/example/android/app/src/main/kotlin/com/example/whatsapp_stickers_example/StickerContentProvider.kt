package com.example.whatsapp_stickers_example

import com.whatsapp.stickers.BaseStickerContentProvider
import com.whatsapp.stickers.StickerPackData
import com.whatsapp.stickers.StickerData

/**
 * Example ContentProvider for the demo app.
 * 
 * This shows how to implement the ContentProvider required for Android integration.
 */
class StickerContentProvider : BaseStickerContentProvider() {
    
    override fun getStickerPackList(): List<StickerPackData> {
        return listOf(
            StickerPackData(
                identifier = "demo_pack_001",
                name = "Demo Flutter Stickers",
                publisher = "Flutter Plugin Demo",
                trayImageFile = "tray_demo.png",
                publisherWebsite = "https://github.com/043668824/stickers",
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
                        accessibilityText = "Celebration with sparkles and party"
                    )
                )
            )
        )
    }
}