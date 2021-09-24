import 'package:rxdart/rxdart.dart';

class ModeSelector {
  final BehaviorSubject<String> _modeSelector = BehaviorSubject<String>.seeded("Testo");
  Stream<String> get stream$ => _modeSelector.stream;
  String get mode => _modeSelector.value;
  set mode(String mode) {
    _modeSelector.add(mode);
  }

  void toggle() {
    if (mode == "Testo") {
      mode = "Accordi";
    } else {
      mode = "Testo";
    }
  }
}

ModeSelector modeSelectorService = ModeSelector();
