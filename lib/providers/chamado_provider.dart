import 'dart:async';
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subChamados;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subPropostas;
  bool _primeiraCargaPropostas = true;

  String? erro;

  ChamadoProvider() {
    _ouvir();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _ouvir() {
    _subChamados = _db
        .collection('chamados')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .listen((snap) {
      _todos = snap.docs.map((d) => Chamado.fromMap(d.data())).toList();
      erro = null;
      notifyListeners();
    }, onError: (_) {
      erro = 'Não foi possível carregar os chamados.';
      notifyListeners();
    });

    _subPropostas = _db.collection('propostas').snapshots().listen((snap) {
      _propostas = snap.docs.map((d) => Proposta.fromMap(d.data())).toList();

      // Na primeira carga não avisa (são propostas antigas).
      if (!_primeiraCargaPropostas) {
        for (final mudanca in snap.docChanges) {
          if (mudanca.type == DocumentChangeType.added &&
              mudanca.doc.data() != null) {
            _avisar(Proposta.fromMap(mudanca.doc.data()!));
          }
        }
      }
      _primeiraCargaPropostas = false;
      notifyListeners();
    }, onError: (_) {
      erro = 'Não foi possível carregar as propostas.';
      notifyListeners();
    });
  }

  void _avisar(Proposta p) {
    final uid = _uid;
    if (uid == null) return;
    final meu = _todos.any((c) => c.id == p.chamadoId && c.clienteId == uid);
    if (!meu) return;

    final valor = p.valor.toStringAsFixed(2).replaceAll('.', ',');
    NotificationService.instance.mostrar(
      'Nova proposta recebida',
      '${p.prestadorNome} enviou um orçamento de R\$ $valor',
    );
  }


  List<Chamado> get chamados =>
      _todos.where((c) => c.clienteId == _uid).toList();

  List<Chamado> get chamadosAbertos => _todos
      .where((c) =>
  c.status == StatusChamado.aberto ||
      c.status == StatusChamado.comProposta)
      .toList();

  List<Proposta> propostasDo(String chamadoId) =>
      _propostas.where((p) => p.chamadoId == chamadoId).toList();

  Future<void> criarChamado(Chamado chamado) async {
    var c = chamado.copyWith(clienteId: _uid ?? '');
    if (c.fotoPath != null) {
      final caminho = await CameraService.salvarPermanente(c.fotoPath!);
      c = c.copyWith(fotoPath: caminho);
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

  List<({Chamado chamado, double km})> chamadosAbertosPerto(
      double lat, double lng) {
    return chamadosAbertos
        .map((c) => (chamado: c, km: distanciaKm(lat, lng, c.lat, c.lng)))
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));
  }

  @override
  void dispose() {
    _subChamados?.cancel();
    _subPropostas?.cancel();
    super.dispose();
  }
}