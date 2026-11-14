import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/proposta.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chamado_provider.dart';
import '../contraproposta_screen.dart';

class MinhasPropostasScreen extends StatelessWidget {
  const MinhasPropostasScreen({super.key});

  String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _rotulo(Proposta p) {
    switch (p.status) {
      case StatusProposta.aceita:
        return 'Aceita';
      case StatusProposta.recusada:
        return 'Recusada';
      default:
        return p.vezDoPrestador
            ? 'O cliente respondeu: sua vez'
            : 'Aguardando o cliente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChamadoProvider>();
    final uid = context.watch<AuthProvider>().usuario?.id ?? '';
    final propostas = prov.propostasDoPrestador(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas propostas')),
      body: propostas.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Você ainda não enviou propostas.'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: propostas.length,
        itemBuilder: (_, i) {
          final p = propostas[i];
          final chamado = prov.chamadoPorId(p.chamadoId);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(chamado?.titulo ?? 'Chamado',
                          style:
                          Theme.of(context).textTheme.titleMedium),
                    ),
                    Text(_moeda(p.valor),
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 4),
                  Text(_rotulo(p)),
                  if (p.vezDoPrestador) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilledButton(
                          onPressed: () => context
                              .read<ChamadoProvider>()
                              .aceitarProposta(p.id),
                          child: Text('Aceitar ${_moeda(p.valor)}'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContrapropostaScreen(
                                  proposta: p, ehCliente: false),
                            ),
                          ),
                          child: const Text('Contraproposta'),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<ChamadoProvider>()
                              .recusarProposta(p.id),
                          child: const Text('Recusar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}