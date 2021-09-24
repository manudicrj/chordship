import 'package:chordship/views/search_view.dart';
import 'package:chordship/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int currentPage = 1;
  List<Widget> widgets = [const SearchView(), const Text("empty"), const Text("empty"), const LoginView()];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: widgets.length);

    _tabController.addListener(() {
      if (currentPage != _tabController.index + 1) {
        setState(() {
          currentPage = _tabController.index + 1;
          print(currentPage);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget currentView = widgets[currentPage - 1];
    return DefaultTabController(
      length: widgets.length,
      child: Scaffold(
        backgroundColor: const Color(0xfffbfbfb),
        body: TabBarView(
          controller: _tabController,
          children: widgets,
        ),
        bottomNavigationBar: NavBarWidget(
          selected: currentPage,
          onPressed: (int button) {
            setState(() {
              currentPage = button;
              _tabController.animateTo(currentPage - 1);
            });
          },
          items: const [
            NavBarItem(
              id: 1,
              icon: Icon(Icons.search_rounded),
              text: "Sfoglia",
              color: Color(0xff5b37b7),
            ),
            NavBarItem(
              id: 2,
              icon: Icon(Icons.menu_book_rounded),
              text: "Innari",
              color: Color(0xffc9379d),
            ),
            NavBarItem(
              id: 3,
              icon: Icon(Icons.person_outline_rounded),
              text: "Offline",
              color: Color(0xff1194aa),
            ),
            NavBarItem(
              id: 4,
              icon: Icon(Icons.mode_edit_outlined),
              text: "Impostazioni",
              color: Color(0xffe6a919),
            ),
          ],
        ),
      ),
    );
  }
}
