import 'dart:async';

class Event {
  Event() {
    _streamController = StreamController<dynamic>.broadcast(sync: true);
  }
  StreamController<dynamic>? _streamController;

  Stream<dynamic>? _getStream() {
    return _streamController?.stream;
  }

  void dispose() {
    _streamController?.close();
  }

  void listen(void Function(dynamic event) callback) {
    final stream = _getStream();
    stream?.listen(callback);
  }

  void publish(dynamic event) {
    _streamController?.add(event);
  }
}
