import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/models/chamado.dart';
import '../core/models/proposta.dart';
import '../core/services/camera_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/distance_utils.dart';

class ChamadoProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Chamado> _todos = [];
  List<Proposta> _propostas = [];
  StreamSubscription<User?>? _subAuth;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subChamados;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subPropostas;
  bool _primeiraCargaPropostas = true;

  String? erro;

  ChamadoProvider() {
    _subAuth = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _pararEscuta();
        _todos = [];
        _propostas = [];
        notifyListeners();
      } else {
        _iniciarEscuta();
      }
    });
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _pararEscuta() {
    _subChamados?.cancel();
    _subPropostas?.cancel();
    _subChamados = null;
    _subPropostas = null;
  }

  void _iniciarEscuta() {
    _pararEscuta();
    _primeiraCargaPropostas = true;

    _subChamados = _db
        .collection('chamados')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .listen((snap) {
      _todos = snap.docs.map((d) => Chamado.fromMap(d.data())).toList();
      erro = null;
      notifyListeners();
    }, onError: (e) {
      erro = 'Não foi possível carregar os chamados.';
      debugPrint('Erro chamados: $e');
      notifyListeners();
    });

    _subPropostas = _db.collection('propostas').snapshots().listen((snap) {
      _propostas = snap.docs.map((d) => Proposta.fromMap(d.data())).toList();

      if (!_primeiraCargaPropostas) {
        for (final m in snap.docChanges) {
          final data = m.doc.data();
          if (data == null) continue;
          final p = Proposta.fromMap(data);

          if (m.type == DocumentChangeType.added) {
            _avisarNovaProposta(p);
          } else if (m.type == DocumentChangeType.modified &&
              p.status == StatusProposta.negociando) {
            _avisarContraproposta(p);
          }
        }
      }
      _primeiraCargaPropostas = false;
      notifyListeners();
    }, onError: (e) {
      erro = 'Não foi possível carregar as propostas.';
      debugPrint('Erro propostas: $e');
      notifyListeners();
    });
  }

  String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  void _avisarNovaProposta(Proposta p) {
    final uid = _uid;
    if (uid == null) return;
    final meu = _todos.any((c) => c.id == p.chamadoId && c.clienteId == uid);
    if (!meu) return;
    NotificationService.instance.mostrar(
      'Nova proposta recebida',
      '${p.prestadorNome} enviou um orçamento de ${_moeda(p.valor)}',
    );
  }

  void _avisarContraproposta(Proposta p) {
    final uid = _uid;
    if (uid == null) return;

    if (p.ultimoOfertante == 'cliente' && p.prestadorId == uid) {
      NotificationService.instance.mostrar(
        'Contraproposta do cliente',
        'O cliente ofereceu ${_moeda(p.valor)}. Aceite ou responda.',
      );
    } else if (p.ultimoOfertante == 'prestador') {
      final meu = _todos.any((c) => c.id == p.chamadoId && c.clienteId == uid);
      if (meu) {
        NotificationService.instance.mostrar(
          'Contraproposta do prestador',
          '${p.prestadorNome} ofereceu ${_moeda(p.valor)}. Aceite ou responda.',
        );
      }
    }
  }

  List<Chamado> get chamados =>
      _todos.where((c) => c.clienteId == _uid).toList();


  List<Chamado> get chamadosAbertos => _todos
      .where((c) =>
  c.status == StatusChamado.aberto ||
      c.status == StatusChamado.comProposta)
      .toList();

  Chamado? chamadoPorId(String id) {
    for (final c in _todos) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Proposta> propostasDo(String chamadoId) =>
      _propostas.where((p) => p.chamadoId == chamadoId).toList();

  List<Proposta> propostasDoPrestador(String prestadorId) =>
      _propostas.where((p) => p.prestadorId == prestadorId).toList()
        ..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));

  Future<void> criarChamado(Chamado chamado) async {
    var c = chamado.copyWith(clienteId: _uid ?? '');

    if (c.fotoPath != null) {
      final caminho = await CameraService.salvarPermanente(c.fotoPath!);
      c = c.copyWith(fotoPath: caminho);
      try {
        final bytes = await File(caminho).readAsBytes();
        if (bytes.length <= 700 * 1024) {
          c = c.copyWith(fotoBase64: base64Encode(bytes));
        }
      } catch (_) {}
    }

    await _db.collection('chamados').doc(c.id).set(c.toMap());
  }

  Future<void> adicionarProposta(Proposta proposta) async {
    final batch = _db.batch();
    batch.set(_db.collection('propostas').doc(proposta.id), proposta.toMap());
    batch.update(_db.collection('chamados').doc(proposta.chamadoId),
        {'status': StatusChamado.comProposta.name});
    await batch.commit();
  }

  Future<void> aceitarProposta(String propostaId) async {
    final aceita = _propostas.where((p) => p.id == propostaId).firstOrNull;
    if (aceita == null) return;

    final batch = _db.batch();
    for (final p in propostasDo(aceita.chamadoId)) {
      batch.update(_db.collection('propostas').doc(p.id), {
        'status': (p.id == propostaId
            ? StatusProposta.aceita
            : StatusProposta.recusada)
            .name,
      });
    }
    batch.update(_db.collection('chamados').doc(aceita.chamadoId),
        {'status': StatusChamado.aceito.name});
    await batch.commit();
  }

  Future<void> recusarProposta(String propostaId) async {
    await _db
        .collection('propostas')
        .doc(propostaId)
        .update({'status': StatusProposta.recusada.name});
  }

  Future<void> contraproposta(
      String propostaId,
      double valor, {
        required bool porCliente,
      }) async {
    await _db.collection('propostas').doc(propostaId).update({
      'valor': valor,
      'ultimoOfertante': porCliente ? 'cliente' : 'prestador',
      'status': StatusProposta.negociando.name,
    });
  }

  List<({Chamado chamado, double km})> chamadosAbertosPerto(
      double lat, double lng) {
    return chamadosAbertos
        .map((c) => (chamado: c, km: distanciaKm(lat, lng, c.lat, c.lng)))
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));
  }

  @override
  void dispose() {
    _subAuth?.cancel();
    _pararEscuta();
    super.dispose();
  }
}