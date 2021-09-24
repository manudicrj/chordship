import 'dart:convert';
import 'dart:developer';

import 'package:chordship/main.dart';
import 'package:chordship/services/web_service.dart';
import 'package:chordship/views/search_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final WebService api = WebService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    fillColor: const Color(0x10000000),
                    focusColor: const Color(0x11000000),
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Email',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    fillColor: const Color(0x10000000),
                    focusColor: const Color(0x11000000),
                    filled: true,
                    border: InputBorder.none,
                    hintText: 'Password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0x00000000)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CupertinoButton.filled(
                  child: const SizedBox(
                    width: double.maxFinite,
                    child: Center(
                      child: Text(
                        "ENTRA",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final response = await api.logIn(emailController.text, passwordController.text);
                    final Map<String, dynamic> message = jsonDecode(response.body) as Map<String, dynamic>;
                    if (message['loggedIn'] as bool == true) {
                      navigatorKey.currentState!.pushReplacement(
                        MaterialPageRoute(
                          builder: (builder) => const SearchView(),
                        ),
                      );
                    } else {
                      final Widget okButton = TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      );
                      final AlertDialog alert = AlertDialog(
                        title: const Text("Errore"),
                        content: const Text("Credenziali errate"),
                        actions: [
                          okButton,
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Non hai un account?"),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Registrati",
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
      /*
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/login_worship_bg.jpg"), fit: BoxFit.cover),
        ),
        child: Container(
          //margin: const EdgeInsets.only(top: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [],
          ),
        ),
      ),*/
    );
  }
}
