import 'package:chordship/services/action_selector_service.dart';
import 'package:chordship/services/mode_selector_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:flutter/material.dart';

class ActionSelectorWidget extends StatelessWidget {
  const ActionSelectorWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: modeSelectorService.stream$,
      builder: (context, snap) {
        final bool accordi = snap.data == "Accordi";
        return StreamBuilder<String>(
          stream: actionSelectorService.stream$,
          builder: (context, snap) {
            String selectedMode = "";
            if (snap.hasData) {
              selectedMode = snap.data!;
            } else {
              selectedMode = "Aggiungi";
            }
            return accordi
                ? Listener(
                    onPointerDown: (details) {
                      actionSelectorService.toggle();
                    },
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                  child: const Icon(Icons.edit, color: Color(0x66000000), size: 30),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                  child: const Icon(Icons.delete, color: Color(0x66000000), size: 30),
                                ),
                              ],
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              right: selectedMode == "Aggiungi" ? 43 : 0,
                              left: selectedMode == "Elimina" ? 43 : 0,
                              bottom: 0,
                              top: 0,
                              curve: Curves.fastOutSlowIn,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Palette.secondary,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  child: Icon(
                                    selectedMode == "Aggiungi" ? Icons.edit : Icons.delete,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Container();
          },
        );
      },
    );
  }
}
