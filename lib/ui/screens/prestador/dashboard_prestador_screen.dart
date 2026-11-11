import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chamado.dart';
import '../../../core/models/proposta.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chamado_provider.dart';
import '../../../providers/location_provider.dart';
import '../../widgets/foto_chamado.dart';
import '../../widgets/mapa_chamado.dart';
import '../perfil/perfil_screen.dart';

class DashboardPrestadorScreen extends StatelessWidget {
  const DashboardPrestadorScreen({super.key});

  String _formatarDistancia(double km) => km < 1
      ? '${(km * 1000).round()} m'
      : '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

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
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final v = double.tryParse(valor.text.replaceAll(',', '.'));
              if (v == null || v <= 0) return;
              final agora = DateTime.now();
              Navigator.pop(dialogCtx);
              await prov.adicionarProposta(Proposta(
                id: 'prop_${agora.millisecondsSinceEpoch}',
                chamadoId: c.id,
                prestadorId: usuario.id,
                prestadorNome: usuario.nome,
                valor: v,
                mensagem: msg.text.trim(),
                criadaEm: agora,
              ));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proposta enviada!')),
                );
              }
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

    final esp = usuario?.especialidade;
    final filtrados =
    esp == null ? todos : todos.where((c) => c.categoria == esp).toList();

    final itens = filtrados
        .map((c) =>
    (chamado: c, km: distanciaKm(loc.lat, loc.lng, c.lat, c.lng)))
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados na sua região'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            ),
          ),
        ],
      ),
      body: itens.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Nenhum chamado aberto na sua especialidade.'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: itens.length,
        itemBuilder: (_, i) {
          final c = itens[i].chamado;
          final dist = _formatarDistancia(itens[i].km);

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FotoChamado(chamado: c),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.titulo,
                          style:
                          Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          Icon(c.categoria.icone,
                              size: 18, color: c.categoria.cor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                '${c.categoria.nome} • $dist de você'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c.descricao),
                      const SizedBox(height: 10),
                      MapaChamado(
                        lat: c.lat,
                        lng: c.lng,
                        titulo: c.titulo,
                      ),
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