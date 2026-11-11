import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../auth/navegacao.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().usuario;
    if (u == null) return const Scaffold(body: SizedBox.shrink());
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: tema.colorScheme.primaryContainer,
              child: Text(
                u.nome.isNotEmpty ? u.nome[0].toUpperCase() : '?',
                style: tema.textTheme.displaySmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(u.nome,
              textAlign: TextAlign.center, style: tema.textTheme.headlineSmall),
          Center(
            child: Chip(
              avatar:
              Icon(u.ehPrestador ? Icons.handyman : Icons.person, size: 18),
              label: Text(u.ehPrestador ? 'Prestador' : 'Cliente'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('E-mail'),
                  subtitle: Text(u.email),
                ),
                if (u.ehPrestador) ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Telefone'),
                    subtitle: Text(u.telefone ?? '-'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.build),
                    title: const Text('Especialidade'),
                    subtitle: Text(u.especialidade?.nome ?? '-'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            onPressed: () async {
              await context.read<AuthProvider>().sair();
              if (!context.mounted) return;
              irParaInicio(context);
            },
          ),
        ],
      ),
    );
  }
}