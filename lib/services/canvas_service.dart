import 'package:rxdart/rxdart.dart';

class CanvasService {
  final BehaviorSubject<int> _state = BehaviorSubject<int>.seeded(0);
  Stream<int> get stream$ => _state.stream;
  int get action => _state.value;

  void update() {
    _state.add(0);
  }
}

CanvasService canvasService = CanvasService();

class KeyInputService {
  final BehaviorSubject<int> _state = BehaviorSubject<int>.seeded(0);
  Stream<int> get stream$ => _state.stream;
  int get action => _state.value;

  void update() {
    _state.add(0);
  }
}

KeyInputService keyInputService = KeyInputService();
