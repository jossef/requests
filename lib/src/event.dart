import 'dart:async';

class Event {
  StreamController<dynamic> _streamController;

  Event() {
    this._streamController = StreamController<dynamic>.broadcast(sync: true);
  }

  Stream<dynamic> _getStream() {
    return _streamController?.stream;
  }

  void dispose() {
    if (_streamController != null) {
      _streamController.close();
      _streamController = null;
    }
  }

  void listen(void callback(dynamic event)) {
    Stream<dynamic> stream = _getStream();
    stream.listen(callback);
  }

  void publish(dynamic event) {
    if (_streamController != null) {
      _streamController.add(event);
    }
  }
}
