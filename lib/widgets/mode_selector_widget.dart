import 'package:chordship/services/mode_selector_service.dart';
import 'package:chordship/services/palette_service.dart';
import 'package:flutter/material.dart';

class ModeSelectorWidget extends StatelessWidget {
  const ModeSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double chipModeWidth = 120;
    return StreamBuilder<String>(
      stream: modeSelectorService.stream$,
      builder: (context, snap) {
        final String selectedMode = snap.hasData ? snap.data! : "Testo";
        return Listener(
          onPointerDown: (details) {
            modeSelectorService.toggle();
          },
          child: FittedBox(
            fit: BoxFit.none,
            child: Container(
              alignment: Alignment.center,
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
                        width: chipModeWidth,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        child: const Text(
                          "Testo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: chipModeWidth,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        child: const Text(
                          "Accordi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    right: selectedMode == "Testo" ? chipModeWidth : 0,
                    left: selectedMode == "Accordi" ? chipModeWidth : 0,
                    bottom: 0,
                    top: 0,
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Palette.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        child: Text(
                          selectedMode,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
