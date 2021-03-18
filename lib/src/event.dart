import 'dart:async';

class Event {
  late StreamController<dynamic> _streamController;

  Event() {
    _streamController = StreamController<dynamic>.broadcast(sync: true);
  }

  Stream<dynamic> _getStream() {
    return _streamController.stream;
  }

  void dispose() {
    _streamController.close();
  }

  void listen(void Function(dynamic event) callback) {
    var stream = _getStream();
    stream.listen(callback);
  }

  void publish(dynamic event) {
    _streamController.add(event);
  }
}
