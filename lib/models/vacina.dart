class Vacina {
  int? id;
  int petId;
  String vacina;
  String veterinario;
  String crmv;
  double peso;
  String lote;
  DateTime? fabricacao;
  DateTime? vencimento;
  DateTime dataAplicacao;
  DateTime proxima;

  Vacina({
    this.id,
    required this.petId,
    required this.vacina,
    required this.veterinario,
    required this.crmv,
    required this.peso,
    required this.lote,
    this.fabricacao,
    this.vencimento,
    required this.dataAplicacao,
    required this.proxima,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'petId': petId,
    'vacina': vacina,
    'veterinario': veterinario,
    'crmv': crmv,
    'peso': peso,
    'lote': lote,
    'fabricacao': fabricacao?.toIso8601String(),
    'vencimento': vencimento?.toIso8601String(),
    'dataAplicacao': dataAplicacao.toIso8601String(),
    'proxima': proxima.toIso8601String(),
  };

  factory Vacina.fromMap(Map<String, dynamic> map) => Vacina(
    id: map['id'],
    petId: map['petId'],
    vacina: map['vacina'],
    veterinario: map['veterinario'],
    crmv: map['crmv'],
    peso: map['peso'],
    lote: map['lote'],
    fabricacao: map['fabricacao'] != null ? DateTime.parse(map['fabricacao']) : null,
    vencimento: map['vencimento'] != null ? DateTime.parse(map['vencimento']) : null,
    dataAplicacao: DateTime.parse(map['dataAplicacao']),
    proxima: DateTime.parse(map['proxima']),
  );
}
