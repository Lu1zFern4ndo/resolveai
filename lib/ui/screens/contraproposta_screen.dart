import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/proposta.dart';
import '../../providers/chamado_provider.dart';

class ContrapropostaScreen extends StatefulWidget {
  final Proposta proposta;
  final bool ehCliente;

  const ContrapropostaScreen({
    super.key,
    required this.proposta,
    required this.ehCliente,
  });

  @override
  State<ContrapropostaScreen> createState() => _ContrapropostaScreenState();
}

class _ContrapropostaScreenState extends State<ContrapropostaScreen> {
  final _valor = TextEditingController();
  String? _erro;
  bool _enviando = false;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  Future<void> _enviar() async {
    final v = double.tryParse(_valor.text.replaceAll(',', '.'));
    if (v == null || v <= 0) {
      setState(() => _erro = 'Informe um valor válido.');
      return;
    }
    final prov = context.read<ChamadoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _erro = null;
      _enviando = true;
    });

    try {
      await prov.contraproposta(widget.proposta.id, v,
          porCliente: widget.ehCliente);
      messenger.showSnackBar(
          const SnackBar(content: Text('Contraproposta enviada!')));
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erro = 'Não foi possível enviar. Verifique sua conexão.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proposta;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Combinar valor')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.request_quote),
              title: Text(widget.ehCliente
                  ? 'Proposta de ${p.prestadorNome}'
                  : 'Oferta atual do cliente'),
              subtitle: const Text('Valor atual'),
              trailing: Text(_moeda(p.valor), style: tema.textTheme.titleLarge),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.ehCliente
                ? 'Quanto você quer pagar?'
                : 'Qual valor você propõe?',
            style: tema.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _valor,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Novo valor (R\$)',
              errorText: _erro,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enviar contraproposta'),
          ),
        ],
      ),
    );
  }
}