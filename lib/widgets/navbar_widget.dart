import 'package:flutter/material.dart';

class NavBarItem extends StatelessWidget {
  const NavBarItem({Key? key, required this.id, this.icon, this.text, this.color, this.selected = false}) : super(key: key);
  final int id;
  final Icon? icon;
  final String? text;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const duration = 600;
    final Color currentColor = color != null && selected ? color! : Colors.black;
    final Curve curve = Curves.easeOutBack;
    return AnimatedContainer(
      curve: curve,
      duration: const Duration(milliseconds: duration),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? currentColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon!.icon,
              color: currentColor,
            )
          else
            Container(),
          AnimatedSize(
            curve: curve,
            duration: const Duration(milliseconds: duration),
            child: FittedBox(
              fit: BoxFit.none,
              child: Container(
                constraints: !selected ? const BoxConstraints(maxWidth: 0.0) : const BoxConstraints(maxWidth: double.maxFinite),
                margin: const EdgeInsets.only(left: 5),
                child: AnimatedOpacity(
                  curve: curve,
                  duration: const Duration(milliseconds: duration),
                  opacity: selected ? 1 : 0,
                  child: text != null
                      ? Text(
                          text!,
                          softWrap: false,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentColor,
                          ),
                        )
                      : const Text(""),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarWidget extends StatelessWidget {
  const NavBarWidget({Key? key, required this.items, required this.onPressed, required this.selected}) : super(key: key);
  final List<NavBarItem> items;
  final Function onPressed;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: SizedBox(
        height: 75,
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i in items)
              InkWell(
                borderRadius: BorderRadius.circular(100),
                splashColor: i.color!.withOpacity(0.1),
                highlightColor: i.color!.withAlpha(20),
                child: NavBarItem(
                  id: i.id,
                  selected: i.id == selected,
                  icon: i.icon,
                  text: i.text,
                  color: i.color,
                ),
                onTap: () {
                  onPressed(i.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
