import 'dart:async';

import 'package:flutter/foundation.dart';

class Debounce {
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 10), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
