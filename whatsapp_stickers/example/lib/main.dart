import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Stickers Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'WhatsApp Stickers Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Ready to test WhatsApp Stickers';
  bool _isLoading = false;

  Future<void> _checkWhatsAppInstalled() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking WhatsApp installation...';
    });

    final result = await WhatsAppStickers.isWhatsAppInstalled();
    
    setState(() {
      _isLoading = false;
      _status = switch (result) {
        WhatsAppSuccess(:final data) => 
          data ? '✅ WhatsApp is installed' : '❌ WhatsApp is not installed',
        WhatsAppError(:final message) => 
          '❌ Error checking WhatsApp: $message',
      };
    });
  }

  Future<void> _addDemoStickerPack() async {
    setState(() {
      _isLoading = true;
      _status = 'Preparing demo sticker pack...';
    });

    try {
      // Load demo assets
      final trayImageData = await _loadAsset('assets/tray_images/demo_tray.png');
      final stickerData1 = await _loadAsset('assets/stickers/sticker1.webp');
      final stickerData2 = await _loadAsset('assets/stickers/sticker2.webp');
      final stickerData3 = await _loadAsset('assets/stickers/sticker3.webp');

      // Create demo stickers
      final stickers = [
        Sticker(
          imageFileName: 'sticker1.webp',
          imageData: stickerData1,
          emojis: ['😀', '👋'],
          accessibilityText: 'A smiling face waving hello',
        ),
        Sticker(
          imageFileName: 'sticker2.webp',
          imageData: stickerData2,
          emojis: ['❤️', '😍'],
          accessibilityText: 'A heart with loving eyes',
        ),
        Sticker(
          imageFileName: 'sticker3.webp',
          imageData: stickerData3,
          emojis: ['🎉', '✨'],
          accessibilityText: 'Celebration with sparkles',
        ),
      ];

      // Create demo sticker pack
      final stickerPack = StickerPack(
        identifier: 'demo_pack_001',
        name: 'Demo Stickers',
        publisher: 'Flutter Plugin Demo',
        trayImageData: trayImageData,
        stickers: stickers,
        publisherWebsite: 'https://github.com/043668824/stickers',
      );

      setState(() {
        _status = 'Adding sticker pack to WhatsApp...';
      });

      // Add to WhatsApp
      final result = await WhatsAppStickers.addStickerPack(stickerPack);
      
      setState(() {
        _isLoading = false;
        _status = switch (result) {
          WhatsAppSuccess(:final data) => 
            data ? '✅ Sticker pack added successfully!' : '❌ Failed to add sticker pack',
          WhatsAppError(:final message, :final details) => 
            '❌ Error: $message${details != null ? '\nDetails: $details' : ''}',
        };
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error creating demo pack: $e';
      });
    }
  }

  Future<Uint8List> _loadAsset(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      // For demo purposes, create dummy data if asset is not found
      return Uint8List.fromList(List.generate(100, (index) => index % 256));
    }
  }

  Future<void> _validateDemoStickerPack() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating and validating demo sticker pack...';
    });

    try {
      // Create a simple demo pack for validation
      final demoStickers = [
        Sticker(
          imageFileName: 'demo1.webp',
          imageData: Uint8List.fromList(List.generate(1000, (i) => i % 256)),
          emojis: ['😀'],
          accessibilityText: 'Demo sticker',
        ),
        Sticker(
          imageFileName: 'demo2.webp',
          imageData: Uint8List.fromList(List.generate(1000, (i) => i % 256)),
          emojis: ['👋'],
          accessibilityText: 'Another demo sticker',
        ),
        Sticker(
          imageFileName: 'demo3.webp',
          imageData: Uint8List.fromList(List.generate(1000, (i) => i % 256)),
          emojis: ['❤️'],
          accessibilityText: 'Third demo sticker',
        ),
      ];

      final demoStickerPack = StickerPack(
        identifier: 'demo_validation',
        name: 'Validation Demo',
        publisher: 'Flutter Plugin',
        trayImageData: Uint8List.fromList(List.generate(500, (i) => i % 256)),
        stickers: demoStickers,
      );

      final result = await WhatsAppStickers.validateStickerPack(demoStickerPack);
      
      setState(() {
        _isLoading = false;
        _status = switch (result) {
          WhatsAppSuccess(:final data) => 
            data ? '✅ Demo sticker pack is valid!' : '❌ Demo sticker pack validation failed',
          WhatsAppError(:final message, :final details) => 
            '❌ Validation error: $message${details != null ? '\nDetails: $details' : ''}',
        };
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error during validation: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'WhatsApp Stickers Plugin Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _status,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: _checkWhatsAppInstalled,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Check WhatsApp Installation'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _validateDemoStickerPack,
                  icon: const Icon(Icons.verified),
                  label: const Text('Validate Demo Sticker Pack'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addDemoStickerPack,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Demo Sticker Pack'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}