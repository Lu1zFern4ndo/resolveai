import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chamado.dart';
import '../../../core/models/proposta.dart';
import '../../../providers/chamado_provider.dart';
import '../../widgets/foto_chamado.dart';

class PropostasScreen extends StatelessWidget {
  const PropostasScreen({super.key});

  String _rotuloStatus(StatusChamado s) => switch (s) {
    StatusChamado.aberto => 'Aberto',
    StatusChamado.comProposta => 'Com proposta',
    StatusChamado.aceito => 'Aceito',
    StatusChamado.concluido => 'Concluído',
    StatusChamado.cancelado => 'Cancelado',
  };

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChamadoProvider>();
    final chamados = prov.chamados;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus chamados')),
      body: chamados.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Você ainda não abriu chamados.'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: chamados.length,
        itemBuilder: (_, i) {
          final c = chamados[i];
          final propostas = prov.propostasDo(c.id);
          final fechado = c.status == StatusChamado.aceito;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: propostas.isNotEmpty && !fechado,
              leading: CircleAvatar(
                backgroundColor: c.categoria.cor.withValues(alpha: 0.15),
                child: Icon(c.categoria.icone, color: c.categoria.cor),
              ),
              title: Text(c.titulo),
              subtitle: Text(
                  '${c.categoria.nome} • ${_rotuloStatus(c.status)} • ${propostas.length} proposta(s)'),
              children: [
                FotoChamado(chamado: c),
                if (propostas.isEmpty)
                  const ListTile(title: Text('Aguardando propostas...'))
                else
                  for (final p in propostas)
                    ListTile(
                      leading:
                      const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(p.prestadorNome),
                      subtitle: Text(
                          '${p.mensagem}\nR\$ ${p.valor.toStringAsFixed(2).replaceAll('.', ',')}'),
                      isThreeLine: true,
                      trailing: p.status == StatusProposta.aceita
                          ? const Chip(label: Text('Aceita'))
                          : fechado
                          ? const Text('Recusada')
                          : FilledButton(
                        onPressed: () => context
                            .read<ChamadoProvider>()
                            .aceitarProposta(p.id),
                        child: const Text('Aceitar'),
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