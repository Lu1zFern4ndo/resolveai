enum StatusProposta { pendente, aceita, recusada, negociando }

class Proposta {
  final String id;
  final String chamadoId;
  final String prestadorId;
  final String prestadorNome;
  final double valor;
  final String mensagem;
  final DateTime? horario;
  final StatusProposta status;
  final String ultimoOfertante; // 'prestador' ou 'cliente'
  final DateTime criadaEm;

  const Proposta({
    required this.id,
    required this.chamadoId,
    required this.prestadorId,
    required this.prestadorNome,
    required this.valor,
    required this.criadaEm,
    this.mensagem = '',
    this.horario,
    this.status = StatusProposta.pendente,
    this.ultimoOfertante = 'prestador',
  });

  bool get encerrada =>
      status == StatusProposta.aceita || status == StatusProposta.recusada;

  /// O cliente pode responder (a última oferta foi do prestador).
  bool get vezDoCliente => !encerrada && ultimoOfertante == 'prestador';

  /// O prestador pode responder (a última oferta foi do cliente).
  bool get vezDoPrestador => !encerrada && ultimoOfertante == 'cliente';

  Map<String, dynamic> toMap() => {
    'id': id,
    'chamadoId': chamadoId,
    'prestadorId': prestadorId,
    'prestadorNome': prestadorNome,
    'valor': valor,
    'mensagem': mensagem,
    'horario': horario?.toIso8601String(),
    'status': status.name,
    'ultimoOfertante': ultimoOfertante,
    'criadaEm': criadaEm.toIso8601String(),
  };

  factory Proposta.fromMap(Map<String, dynamic> map) => Proposta(
    id: map['id'] as String,
    chamadoId: map['chamadoId'] as String,
    prestadorId: map['prestadorId'] as String,
    prestadorNome: map['prestadorNome'] as String,
    valor: (map['valor'] as num).toDouble(),
    mensagem: map['mensagem'] as String? ?? '',
    horario: map['horario'] == null
        ? null
        : DateTime.parse(map['horario'] as String),
    status: StatusProposta.values.firstWhere(
          (s) => s.name == map['status'],
      orElse: () => StatusProposta.pendente,
    ),
    ultimoOfertante: map['ultimoOfertante'] as String? ?? 'prestador',
    criadaEm: DateTime.parse(map['criadaEm'] as String),
  );
}