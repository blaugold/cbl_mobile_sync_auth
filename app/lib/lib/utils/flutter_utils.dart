import 'package:flutter/foundation.dart';

extension ValueListenableStream<T> on ValueListenable<T> {
  Stream<T> asStream() => Stream.multi((controller) {
        void listener() => controller.add(value);
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
}
