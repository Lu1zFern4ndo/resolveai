import 'package:flutter/foundation.dart';
import '../core/models/chamado.dart';
import '../core/models/proposta.dart';
import '../core/services/notification_service.dart';
import '../core/services/camera_service.dart';

class ChamadoProvider extends ChangeNotifier {
  final List<Chamado> _chamados = [];
  final List<Proposta> _propostas = [];

  List<Chamado> get chamados => List.unmodifiable(_chamados);
  List<Chamado> get chamadosAbertos => _chamados
      .where((c) =>
  c.status == StatusChamado.aberto ||
      c.status == StatusChamado.comProposta)
      .toList();

  List<Proposta> propostasDo(String chamadoId) =>
      _propostas.where((p) => p.chamadoId == chamadoId).toList();

  Future<void> criarChamado(Chamado chamado) async {
    var c = chamado;
    if (c.fotoPath != null) {
      final caminho = await CameraService.salvarPermanente(c.fotoPath!);
      c = c.copyWith(fotoPath: caminho);
    }
    _chamados.insert(0, c);
    notifyListeners();
  }

  void adicionarProposta(Proposta proposta) {
    _propostas.add(proposta);
    _atualizarStatus(proposta.chamadoId, StatusChamado.comProposta);
    notifyListeners();

    final valor = proposta.valor.toStringAsFixed(2).replaceAll('.', ',');
    NotificationService.instance.mostrar(
      'Nova proposta recebida',
      '${proposta.prestadorNome} enviou um orçamento de R\$ $valor',
    );
  }

  void aceitarProposta(String propostaId) {
    final i = _propostas.indexWhere((p) => p.id == propostaId);
    if (i == -1) return;

    final aceita = _propostas[i];
    for (var j = 0; j < _propostas.length; j++) {
      final p = _propostas[j];
      if (p.chamadoId != aceita.chamadoId) continue;
      _propostas[j] = Proposta(
        id: p.id,
        chamadoId: p.chamadoId,
        prestadorId: p.prestadorId,
        prestadorNome: p.prestadorNome,
        valor: p.valor,
        mensagem: p.mensagem,
        criadaEm: p.criadaEm,
        status: p.id == propostaId
            ? StatusProposta.aceita
            : StatusProposta.recusada,
      );
    }
    _atualizarStatus(aceita.chamadoId, StatusChamado.aceito);
    notifyListeners();
  }

  void _atualizarStatus(String chamadoId, StatusChamado status) {
    final i = _chamados.indexWhere((c) => c.id == chamadoId);
    if (i != -1) _chamados[i] = _chamados[i].copyWith(status: status);
  }
}