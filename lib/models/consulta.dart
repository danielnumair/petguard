class Consulta {
  int? id;
  int petId;
  String motivo;
  String veterinario;
  String crmv;
  double peso;
  DateTime data;
  DateTime? proxima;
  String tratamento;

  Consulta({
    this.id,
    required this.petId,
    required this.motivo,
    required this.veterinario,
    required this.crmv,
    required this.peso,
    required this.data,
    this.proxima,
    required this.tratamento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'motivo': motivo,
      'veterinario': veterinario,
      'crmv': crmv,
      'peso': peso,
      'data': data.toIso8601String(),
      'proxima': proxima?.toIso8601String(),
      'tratamento': tratamento,
    };
  }

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id'],
      petId: map['petId'],
      motivo: map['motivo'],
      veterinario: map['veterinario'],
      crmv: map['crmv'],
      peso: map['peso'],
      data: DateTime.parse(map['data']),
      proxima: map['proxima'] != null ? DateTime.parse(map['proxima']) : null,
      tratamento: map['tratamento'],
    );
  }
}
