import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';

void main() {
  group('WhatsAppResult', () {
    test('should create success result correctly', () {
      const result = WhatsAppSuccess('test data');
      
      expect(result.data, equals('test data'));
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.errorMessage, isNull);
    });
    
    test('should create error result correctly', () {
      const result = WhatsAppError<String>('Error message', code: 'ERROR_CODE');
      
      expect(result.message, equals('Error message'));
      expect(result.code, equals('ERROR_CODE'));
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.data, isNull);
      expect(result.errorMessage, equals('Error message'));
    });
    
    test('should map success values correctly', () {
      const result = WhatsAppSuccess(42);
      final mapped = result.map((value) => value.toString());
      
      expect(mapped, isA<WhatsAppSuccess<String>>());
      expect(mapped.data, equals('42'));
    });
    
    test('should preserve error when mapping', () {
      const result = WhatsAppError<int>('Error', code: 'CODE');
      final mapped = result.map((value) => value.toString());
      
      expect(mapped, isA<WhatsAppError<String>>());
      expect(mapped.errorMessage, equals('Error'));
      expect((mapped as WhatsAppError).code, equals('CODE'));
    });
    
    test('should fold correctly for success', () {
      const result = WhatsAppSuccess('hello');
      
      final folded = result.fold(
        (data) => 'Success: $data',
        (message, code, details) => 'Error: $message',
      );
      
      expect(folded, equals('Success: hello'));
    });
    
    test('should fold correctly for error', () {
      const result = WhatsAppError<String>('Failed', code: 'FAIL');
      
      final folded = result.fold(
        (data) => 'Success: $data',
        (message, code, details) => 'Error: $message ($code)',
      );
      
      expect(folded, equals('Error: Failed (FAIL)'));
    });
    
    test('should work with pattern matching', () {
      const successResult = WhatsAppSuccess(true);
      const errorResult = WhatsAppError<bool>('Failed');
      
      final successMessage = switch (successResult) {
        WhatsAppSuccess(:final data) => 'Got data: $data',
        WhatsAppError(:final message) => 'Got error: $message',
      };
      
      final errorMessage = switch (errorResult) {
        WhatsAppSuccess(:final data) => 'Got data: $data',
        WhatsAppError(:final message) => 'Got error: $message',
      };
      
      expect(successMessage, equals('Got data: true'));
      expect(errorMessage, equals('Got error: Failed'));
    });
  });
}