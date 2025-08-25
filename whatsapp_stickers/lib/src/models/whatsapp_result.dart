import 'dart:typed_data';

/// Modern Dart 3 result type using sealed classes for type-safe error handling.
sealed class WhatsAppResult<T> {
  const WhatsAppResult();
}

/// Success result containing the expected data.
final class WhatsAppSuccess<T> extends WhatsAppResult<T> {
  const WhatsAppSuccess(this.data);
  final T data;
}

/// Error result containing error information.
final class WhatsAppError<T> extends WhatsAppResult<T> {
  const WhatsAppError(this.message, {this.code, this.details});
  final String message;
  final String? code;
  final Object? details;
}

/// Extension methods for convenient result handling.
extension WhatsAppResultExtension<T> on WhatsAppResult<T> {
  /// Returns true if this is a success result.
  bool get isSuccess => this is WhatsAppSuccess<T>;
  
  /// Returns true if this is an error result.
  bool get isError => this is WhatsAppError<T>;
  
  /// Gets the data if success, null if error.
  T? get data => switch (this) {
    WhatsAppSuccess<T>(:final data) => data,
    WhatsAppError<T>() => null,
  };
  
  /// Gets the error message if error, null if success.
  String? get errorMessage => switch (this) {
    WhatsAppSuccess<T>() => null,
    WhatsAppError<T>(:final message) => message,
  };
  
  /// Transforms the success value using the provided function.
  WhatsAppResult<R> map<R>(R Function(T) transform) => switch (this) {
    WhatsAppSuccess<T>(:final data) => WhatsAppSuccess(transform(data)),
    WhatsAppError<T>(:final message, :final code, :final details) => 
      WhatsAppError(message, code: code, details: details),
  };
  
  /// Executes different functions based on the result type.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(String message, String? code, Object? details) onError,
  ) => switch (this) {
    WhatsAppSuccess<T>(:final data) => onSuccess(data),
    WhatsAppError<T>(:final message, :final code, :final details) => 
      onError(message, code, details),
  };
}