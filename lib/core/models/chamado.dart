import 'categoria_servico.dart';

enum StatusChamado { aberto, comProposta, aceito, concluido, cancelado }

class Chamado {
  final String id;
  final String clienteId;
  final String titulo;
  final String descricao;
  final CategoriaServico categoria;
  final String? fotoPath;
  final double lat;
  final double lng;
  final StatusChamado status;
  final DateTime criadoEm;

  const Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.lat,
    required this.lng,
    required this.criadoEm,
    this.clienteId = '',
    this.fotoPath,
    this.status = StatusChamado.aberto,
  });

  Chamado copyWith({
    StatusChamado? status,
    String? fotoPath,
    String? clienteId,
  }) =>
      Chamado(
        id: id,
        clienteId: clienteId ?? this.clienteId,
        titulo: titulo,
        descricao: descricao,
        categoria: categoria,
        lat: lat,
        lng: lng,
        criadoEm: criadoEm,
        fotoPath: fotoPath ?? this.fotoPath,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'clienteId': clienteId,
    'titulo': titulo,
    'descricao': descricao,
    'categoria': categoria.name,
    'fotoPath': fotoPath,
    'lat': lat,
    'lng': lng,
    'status': status.name,
    'criadoEm': criadoEm.toIso8601String(),
  };

  factory Chamado.fromMap(Map<String, dynamic> map) => Chamado(
    id: map['id'] as String,
    clienteId: map['clienteId'] as String? ?? '',
    titulo: map['titulo'] as String,
    descricao: map['descricao'] as String? ?? '',
    categoria: CategoriaServico.fromName(map['categoria'] as String?),
    fotoPath: map['fotoPath'] as String?,
    lat: (map['lat'] as num).toDouble(),
    lng: (map['lng'] as num).toDouble(),
    status: StatusChamado.values.firstWhere(
          (s) => s.name == map['status'],
      orElse: () => StatusChamado.aberto,
    ),
    criadoEm: DateTime.parse(map['criadoEm'] as String),
  );
}