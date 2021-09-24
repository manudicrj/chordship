import 'package:rxdart/rxdart.dart';

class ActionSelector {
  final BehaviorSubject<String> _actionSelector = BehaviorSubject<String>.seeded("Aggiungi");
  Stream<String> get stream$ => _actionSelector.stream;
  String get action => _actionSelector.value;
  set action(String mode) {
    _actionSelector.add(mode);
  }

  void toggle() {
    if (action == "Aggiungi") {
      action = "Elimina";
    } else {
      action = "Aggiungi";
    }
  }
}

ActionSelector actionSelectorService = ActionSelector();
