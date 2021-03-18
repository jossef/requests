import 'dart:async';

class Event {
  late StreamController<dynamic> _streamController;

  Event() {
    this._streamController = StreamController<dynamic>.broadcast(sync: true);
  }

  Stream<dynamic> _getStream() {
    return _streamController.stream;
  }

  void dispose() {
    _streamController.close();
  }

  void listen(void callback(dynamic event)) {
    Stream<dynamic> stream = _getStream();
    stream.listen(callback);
  }

  void publish(dynamic event) {
    _streamController.add(event);
  }
}
