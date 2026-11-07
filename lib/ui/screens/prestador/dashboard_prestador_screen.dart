import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chamado.dart';
import '../../../core/models/prestador.dart';
import '../../../core/models/proposta.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../core/utils/mock_data.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chamado_provider.dart';
import '../../../providers/location_provider.dart';
import '../../screens/perfil/perfil_screen.dart';

class DashboardPrestadorScreen extends StatelessWidget {
  const DashboardPrestadorScreen({super.key});

  Prestador? _buscarPrestador(String id) {
    for (final p in prestadoresMock) {
      if (p.id == id) return p;
    }
    return null;
  }

  void _enviarProposta(BuildContext context, Chamado c) {
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;
    final prov = context.read<ChamadoProvider>();
    final valor = TextEditingController();
    final msg = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Proposta: ${c.titulo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valor,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msg,
              decoration: const InputDecoration(labelText: 'Mensagem'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(valor.text.replaceAll(',', '.'));
              if (v == null || v <= 0) return;
              final agora = DateTime.now();
              prov.adicionarProposta(Proposta(
                id: 'prop_${agora.millisecondsSinceEpoch}',
                chamadoId: c.id,
                prestadorId: usuario.id,
                prestadorNome: usuario.nome,
                valor: v,
                mensagem: msg.text.trim(),
                criadaEm: agora,
              ));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<ChamadoProvider>().chamadosAbertos;
    final loc = context.watch<LocationProvider>();
    final usuario = context.watch<AuthProvider>().usuario;

    // Se o prestador existe no mock, mostra só chamados da especialidade dele.
    final meu = usuario == null ? null : _buscarPrestador(usuario.id);
    final chamados = meu == null
        ? todos
        : todos.where((c) => c.categoria == meu.categoria).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados na sua região'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
        ],
      ),
      body: chamados.isEmpty
          ? const Center(child: Text('Nenhum chamado aberto.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chamados.length,
              itemBuilder: (_, i) {
                final c = chamados[i];
                final km = distanciaKm(loc.lat, loc.lng, c.lat, c.lng);
                final dist = km < 1
                    ? '${(km * 1000).round()} m'
                    : '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.fotoPath != null)
                        Image.file(
                          File(c.fotoPath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.titulo,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            Text('${c.categoria.nome} • $dist de você'),
                            const SizedBox(height: 6),
                            Text(c.descricao),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () => _enviarProposta(context, c),
                                icon: const Icon(Icons.request_quote),
                                label: const Text('Enviar proposta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
