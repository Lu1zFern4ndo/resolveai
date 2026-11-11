import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Usuario? usuario;
  String? erro;
  bool carregando = false;

  bool get logado => usuario != null;

  AuthProvider() {
    _restaurarSessao();
  }

  /// Se já havia sessão aberta, recarrega o perfil.
  Future<void> _restaurarSessao() async {
    final atual = _auth.currentUser;
    if (atual == null) return;
    try {
      usuario = await _carregarPerfil(atual);
      notifyListeners();
    } catch (_) {}
  }

  Future<Usuario> _carregarPerfil(User u) async {
    final doc = await _db.collection('usuarios').doc(u.uid).get();
    if (doc.exists) {
      return Usuario.fromMap({...doc.data()!, 'id': u.uid});
    }
    return Usuario(
      id: u.uid,
      nome: u.email ?? 'Usuário',
      email: u.email ?? '',
      tipo: TipoUsuario.cliente,
    );
  }

  Future<bool> entrar(String email, String senha) async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      usuario = await _carregarPerfil(cred.user!);
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      erro = _traduzir(e.code);
    } catch (_) {
      erro = 'Erro inesperado. Verifique sua conexão.';
    }
    carregando = false;
    notifyListeners();
    return false;
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
  }) async {
    carregando = true;
    erro = null;
    notifyListeners();

    if (nome.trim().isEmpty) {
      erro = 'Informe seu nome.';
      carregando = false;
      notifyListeners();
      return false;
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final novo = Usuario(
        id: cred.user!.uid,
        nome: nome.trim(),
        email: email.trim().toLowerCase(),
        tipo: tipo,
      );
      await _db.collection('usuarios').doc(novo.id).set(novo.toMap());
      usuario = novo;
      carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      erro = _traduzir(e.code);
    } catch (_) {
      erro = 'Erro inesperado. Verifique sua conexão.';
    }
    carregando = false;
    notifyListeners();
    return false;
  }

  Future<void> sair() async {
    await _auth.signOut();
    usuario = null;
    erro = null;
    notifyListeners();
  }

  String _traduzir(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em instantes.';
      default:
        return 'Não foi possível concluir ($code).';
    }
  }
}