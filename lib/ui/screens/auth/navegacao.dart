import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../cliente/home_cliente_screen.dart';
import '../prestador/dashboard_prestador_screen.dart';
import 'porta_de_entrada.dart';

void irParaHome(BuildContext context) {
  final u = context.read<AuthProvider>().usuario;
  if (u == null) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => u.ehPrestador
          ? const DashboardPrestadorScreen()
          : const HomeClienteScreen(),
    ),
        (_) => false,
  );
}


void irParaInicio(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const PortaDeEntrada()),
        (_) => false,
  );
}