/// Typed errors + a small sealed [Result] wrapper used by remote calls.
library;

sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'network error', super.cause]);
}

final class TranslationException extends AppException {
  const TranslationException([super.message = 'translation failed', super.cause]);
}

final class StorageException extends AppException {
  const StorageException([super.message = 'storage error', super.cause]);
}

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.exception]);

  final String message;
  final Object? exception;
}
