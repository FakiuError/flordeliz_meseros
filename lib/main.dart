import 'package:flutter/material.dart';
import 'package:flordeliz_meseros/screens/login/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurante Flor de Liz',
        routes: {
          "login" : (_) => SplashScreen(),
        },
        initialRoute: "login",
      ),
    );
  }
}