import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/prestador.dart';
import '../../../core/utils/mock_data.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Prestador? _buscarPrestador(String id) {
    for (final p in prestadoresMock) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().usuario;
    if (u == null) return const Scaffold(body: SizedBox.shrink());

    final dados = u.ehPrestador ? _buscarPrestador(u.id) : null;
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
                if (dados != null) ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Telefone'),
                    subtitle: Text(dados.telefone),
                  ),
                  ListTile(
                    leading: const Icon(Icons.build),
                    title: const Text('Especialidade'),
                    subtitle: Text(dados.categoria.nome),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('Avaliação'),
                    subtitle: Text(dados.avaliacao.toStringAsFixed(1)),
                  ),
                ] else if (u.ehPrestador)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Perfil profissional incompleto'),
                    subtitle: Text(
                        'Especialidade e telefone ainda não cadastrados.'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            onPressed: () {
              context.read<AuthProvider>().sair();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
