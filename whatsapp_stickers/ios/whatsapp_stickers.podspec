#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whatsapp_stickers.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whatsapp_stickers'
  s.version          = '1.0.0'
  s.summary          = 'A modern Flutter plugin for integrating WhatsApp stickers.'
  s.description      = <<-DESC
A modern Flutter plugin for integrating WhatsApp stickers with full Dart 3 compatibility.
Supports both static and animated stickers with comprehensive validation.
                       DESC
  s.homepage         = 'https://github.com/043668824/stickers'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WhatsApp' => 'developer@support.whatsapp.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end