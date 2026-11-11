import 'package:flutter_test/flutter_test.dart';
import 'package:resolveai/core/models/categoria_servico.dart';
import 'package:resolveai/core/models/prestador.dart';
import 'package:resolveai/core/utils/distance_utils.dart';

void main() {
  const latBase = -5.0892;
  const lngBase = -42.8019;

  const perto = Prestador(
    id: 'a',
    nome: 'Perto',
    telefone: '1',
    categoria: CategoriaServico.encanador,
    lat: -5.0850,
    lng: -42.8000,
  );
  const medio = Prestador(
    id: 'b',
    nome: 'Medio',
    telefone: '2',
    categoria: CategoriaServico.eletricista,
    lat: -5.1100,
    lng: -42.7800,
  );
  const longe = Prestador(
    id: 'c',
    nome: 'Longe',
    telefone: '3',
    categoria: CategoriaServico.pintor,
    lat: -5.2200,
    lng: -42.7000,
  );

  group('distanciaKm', () {
    test('distância de um ponto a ele mesmo é zero', () {
      expect(distanciaKm(latBase, lngBase, latBase, lngBase), 0);
    });

    test('é simétrica', () {
      final ida = distanciaKm(latBase, lngBase, perto.lat, perto.lng);
      final volta = distanciaKm(perto.lat, perto.lng, latBase, lngBase);
      expect(ida, closeTo(volta, 0.001));
    });

    test('1 grau de latitude vale cerca de 111 km', () {
      expect(distanciaKm(0, 0, 1, 0), closeTo(111, 1));
    });
  });

  group('filtrarProximos', () {
    test('respeita o raio', () {
      final r = filtrarProximos([perto, medio, longe],
          lat: latBase, lng: lngBase, raioKm: 10);
      final ids = r.map((e) => e.prestador.id).toList();
      expect(ids, contains('a'));
      expect(ids, isNot(contains('c')));
    });

    test('ordena do mais perto ao mais longe', () {
      final r = filtrarProximos([longe, medio, perto],
          lat: latBase, lng: lngBase, raioKm: 50);
      final kms = r.map((e) => e.distanciaKm).toList();
      expect(kms, orderedEquals([...kms]..sort()));
      expect(r.first.prestador.id, 'a');
    });

    test('lista vazia quando ninguém está no raio', () {
      final r = filtrarProximos([longe],
          lat: latBase, lng: lngBase, raioKm: 1);
      expect(r, isEmpty);
    });
  });

  group('distanciaFormatada', () {
    test('abaixo de 1 km usa metros', () {
      expect(const PrestadorComDistancia(perto, 0.5).distanciaFormatada,
          '500 m');
    });

    test('acima de 1 km usa vírgula decimal', () {
      expect(const PrestadorComDistancia(perto, 2.34).distanciaFormatada,
          '2,3 km');
    });
  });
}