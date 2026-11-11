import 'categoria_servico.dart';

enum TipoUsuario { cliente, prestador }

class Usuario {
  final String id;
  final String nome;
  final String email;
  final TipoUsuario tipo;
  final CategoriaServico? especialidade;
  final String? telefone;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.especialidade,
    this.telefone,
  });

  bool get ehCliente => tipo == TipoUsuario.cliente;
  bool get ehPrestador => tipo == TipoUsuario.prestador;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'tipo': tipo.name,
    'especialidade': especialidade?.name,
    'telefone': telefone,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'] as String,
    nome: map['nome'] as String,
    email: map['email'] as String,
    tipo: TipoUsuario.values.firstWhere(
          (t) => t.name == map['tipo'],
      orElse: () => TipoUsuario.cliente,
    ),
    especialidade: map['especialidade'] == null
        ? null
        : CategoriaServico.fromName(map['especialidade'] as String?),
    telefone: map['telefone'] as String?,
  );
}