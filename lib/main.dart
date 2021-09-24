import 'package:chordship/services/palette_service.dart';
import 'package:chordship/services/session_service.dart';
import 'package:chordship/views/home_view.dart';
import 'package:chordship/views/login_view.dart';
import 'package:chordship/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setup() {
  GetIt.I.registerSingleton<SessionService>(SessionService());
}

void main() {
  debugPaintSizeEnabled = false;
  setup();
  runApp(const MyApp());
  /*
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // navigation bar color
    statusBarColor: Colors.white, // status bar color
  ));*/
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  MaterialColor colorToMaterial(int primary) {
    final Color color = Color(primary);
    final Map<int, Color> map = {
      50: color.withOpacity(.1),
      100: color.withOpacity(.2),
      200: color.withOpacity(.3),
      300: color.withOpacity(.4),
      400: color.withOpacity(.5),
      500: color.withOpacity(.6),
      600: color.withOpacity(.7),
      700: color.withOpacity(.8),
      800: color.withOpacity(.9),
      900: color.withOpacity(1),
    };
    return MaterialColor(primary, map);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: Colors.white,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: colorToMaterial(Palette.primaryInt)).copyWith(secondary: Palette.primary),
      ),
      home: const HomeView(),
    );
  }
}
