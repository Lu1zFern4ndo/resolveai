import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chamado.dart';
import '../../../core/models/proposta.dart';
import '../../../providers/chamado_provider.dart';
import '../../widgets/foto_chamado.dart';
import '../../widgets/perfil_prestador_sheet.dart';
import '../contraproposta_screen.dart';

class PropostasScreen extends StatelessWidget {
  const PropostasScreen({super.key});

  String _rotuloStatus(StatusChamado s) => switch (s) {
    StatusChamado.aberto => 'Aberto',
    StatusChamado.comProposta => 'Com proposta',
    StatusChamado.aceito => 'Aceito',
    StatusChamado.concluido => 'Concluído',
    StatusChamado.cancelado => 'Cancelado',
  };

  String _formatarHorario(DateTime d) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} às ${dois(d.hour)}:${dois(d.minute)}';
  }

  Widget _acoes(BuildContext context, Proposta p) {
    final prov = context.read<ChamadoProvider>();

    if (p.status == StatusProposta.aceita) {
      return const Chip(label: Text('Aceita'));
    }
    if (p.status == StatusProposta.recusada) {
      return const Text('Recusada');
    }
    if (!p.vezDoCliente) {
      return const Text('Aguardando resposta do prestador...');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        FilledButton(
          onPressed: () => prov.aceitarProposta(p.id),
          child: const Text('Aceitar'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ContrapropostaScreen(proposta: p, ehCliente: true),
            ),
          ),
          child: const Text('Combinar valor'),
        ),
        TextButton(
          onPressed: () => prov.recusarProposta(p.id),
          child: const Text('Recusar'),
        ),
      ],
    );
  }

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
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => mostrarPerfilPrestador(
                                context, p.prestadorId),
                            child: Row(children: [
                              const CircleAvatar(
                                  child: Icon(Icons.person)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(p.prestadorNome,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const Text('Ver perfil e contato',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.indigo)),
                                  ],
                                ),
                              ),
                              Text(
                                'R\$ ${p.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                            ]),
                          ),
                          if (p.mensagem.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(p.mensagem),
                            ),
                          if (p.horario != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(children: [
                                const Icon(Icons.schedule, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                    'Atende em ${_formatarHorario(p.horario!)}'),
                              ]),
                            ),
                          if (p.status == StatusProposta.negociando)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text('Em negociação',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic)),
                            ),
                          const SizedBox(height: 8),
                          _acoes(context, p),
                          const Divider(),
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