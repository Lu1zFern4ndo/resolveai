import 'package:flutter/material.dart';

enum CategoriaServico {
  encanador('Encanador'),
  eletricista('Eletricista'),
  pedreiro('Pedreiro'),
  pintor('Pintor'),
  tecnicoEletro('Técnico de eletrodomésticos'),
  outros('Outros');

  final String nome;
  const CategoriaServico(this.nome);

  static CategoriaServico fromName(String? name) => CategoriaServico.values
      .firstWhere((c) => c.name == name, orElse: () => CategoriaServico.outros);

  IconData get icone => switch (this) {
    CategoriaServico.encanador => Icons.plumbing,
    CategoriaServico.eletricista => Icons.electrical_services,
    CategoriaServico.pedreiro => Icons.construction,
    CategoriaServico.pintor => Icons.format_paint,
    CategoriaServico.tecnicoEletro => Icons.kitchen,
    CategoriaServico.outros => Icons.handyman,
  };

  Color get cor => switch (this) {
    CategoriaServico.encanador => Colors.blue,
    CategoriaServico.eletricista => Colors.lightBlue,
    CategoriaServico.pedreiro => Colors.blueAccent,
    CategoriaServico.pintor => Colors.blueGrey,
    CategoriaServico.tecnicoEletro => Colors.blueAccent,
    CategoriaServico.outros => Colors.lightBlueAccent,
  };
}