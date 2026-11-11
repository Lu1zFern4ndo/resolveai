import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../cliente/home_cliente_screen.dart';
import '../prestador/dashboard_prestador_screen.dart';
import 'login_screen.dart';

class PortaDeEntrada extends StatelessWidget {
  const PortaDeEntrada({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.restaurando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.logado) return const LoginScreen();
    return auth.usuario!.ehPrestador
        ? const DashboardPrestadorScreen()
        : const HomeClienteScreen();
  }
}