import 'package:flutter/material.dart';
//import 'package:flordeliz_meseros/screens/salon/mesas_screen.dart';
import 'package:flordeliz_meseros/screens/login/login_screen.dart';
import 'package:flordeliz_meseros/services/login/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SplashService _loginService = SplashService();

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2));

    final sesion = await _loginService.getSesion();

    if (sesion == null) {
      _redirigirLogin();
      return;
    }

    final response = await _loginService.verificarUsuario(sesion["idUsuario"]);

    if (response["success"] == true) {
      //Navigator.pushReplacement(
        //context,
        //MaterialPageRoute(
          //builder: (_) => MesasScreen(idUsuario: sesion["idUsuario"]),
        //),
      //);
    } else {
      await _loginService.cerrarSesion();
      _mostrarAlerta(response["message"] ?? "Sesión inválida");
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Sesión inválida"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _redirigirLogin();
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _redirigirLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/quantum_logo.png', width: 180, height: 180),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Cargando...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}