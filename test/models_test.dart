import 'package:flutter_test/flutter_test.dart';
import 'package:resolveai/core/models/categoria_servico.dart';
import 'package:resolveai/core/models/chamado.dart';
import 'package:resolveai/core/models/proposta.dart';
import 'package:resolveai/core/models/usuario.dart';

void main() {
  group('CategoriaServico', () {
    test('fromName reconhece o nome', () {
      expect(CategoriaServico.fromName('pintor'), CategoriaServico.pintor);
    });

    test('fromName desconhecido ou nulo vira outros', () {
      expect(CategoriaServico.fromName('xyz'), CategoriaServico.outros);
      expect(CategoriaServico.fromName(null), CategoriaServico.outros);
    });
  });

  group('Chamado', () {
    final original = Chamado(
      id: '1',
      clienteId: 'u1',
      titulo: 'Infiltração',
      descricao: 'Mancha no teto',
      categoria: CategoriaServico.pedreiro,
      lat: -5.08,
      lng: -42.80,
      criadoEm: DateTime(2026, 11, 11, 10, 30),
      fotoBase64: 'abc',
      status: StatusChamado.comProposta,
    );

    test('toMap e fromMap preservam os dados', () {
      final copia = Chamado.fromMap(original.toMap());
      expect(copia.id, original.id);
      expect(copia.clienteId, original.clienteId);
      expect(copia.titulo, original.titulo);
      expect(copia.categoria, original.categoria);
      expect(copia.lat, original.lat);
      expect(copia.status, StatusChamado.comProposta);
      expect(copia.criadoEm, original.criadoEm);
      expect(copia.fotoBase64, 'abc');
    });

    test('copyWith altera só o que foi pedido', () {
      final c = original.copyWith(status: StatusChamado.aceito);
      expect(c.status, StatusChamado.aceito);
      expect(c.titulo, original.titulo);
    });

    test('temFoto reflete a presença de foto', () {
      expect(original.temFoto, isTrue);
      final sem = Chamado(
        id: '2',
        titulo: 't',
        descricao: 'd',
        categoria: CategoriaServico.outros,
        lat: 0,
        lng: 0,
        criadoEm: DateTime(2026),
      );
      expect(sem.temFoto, isFalse);
    });

    test('status desconhecido cai em aberto', () {
      final map = original.toMap()..['status'] = 'invalido';
      expect(Chamado.fromMap(map).status, StatusChamado.aberto);
    });
  });

  group('Proposta', () {
    test('toMap e fromMap preservam valor e status', () {
      final p = Proposta(
        id: 'p1',
        chamadoId: '1',
        prestadorId: 'x',
        prestadorNome: 'Carlos',
        valor: 180.5,
        mensagem: 'Amanhã',
        criadaEm: DateTime(2026, 11, 11),
        status: StatusProposta.aceita,
      );
      final copia = Proposta.fromMap(p.toMap());
      expect(copia.valor, 180.5);
      expect(copia.status, StatusProposta.aceita);
      expect(copia.prestadorNome, 'Carlos');
    });
  });

  group('Usuario', () {
    test('prestador mantém especialidade e telefone', () {
      const u = Usuario(
        id: '1',
        nome: 'Ana',
        email: 'a@a.com',
        tipo: TipoUsuario.prestador,
        especialidade: CategoriaServico.pintor,
        telefone: '86999990000',
      );
      final copia = Usuario.fromMap(u.toMap());
      expect(copia.ehPrestador, isTrue);
      expect(copia.especialidade, CategoriaServico.pintor);
      expect(copia.telefone, '86999990000');
    });

    test('cliente não tem especialidade', () {
      const u = Usuario(
          id: '2', nome: 'B', email: 'b@b.com', tipo: TipoUsuario.cliente);
      final copia = Usuario.fromMap(u.toMap());
      expect(copia.ehCliente, isTrue);
      expect(copia.especialidade, isNull);
    });
  });
}