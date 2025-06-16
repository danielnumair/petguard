class Vermifugo {
  int? id;
  int petId;
  String produto;
  double peso;
  String dose;
  DateTime data;
  DateTime? proxima;

  Vermifugo({
    this.id,
    required this.petId,
    required this.produto,
    required this.peso,
    required this.dose,
    required this.data,
    this.proxima,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'petId': petId,
    'produto': produto,
    'peso': peso,
    'dose': dose,
    'data': data.toIso8601String(),
    'proxima': proxima?.toIso8601String(),
  };

  factory Vermifugo.fromMap(Map<String, dynamic> map) => Vermifugo(
    id: map['id'],
    petId: map['petId'],
    produto: map['produto'],
    peso: map['peso'],
    dose: map['dose'],
    data: DateTime.parse(map['data']),
    proxima: map['proxima'] != null ? DateTime.parse(map['proxima']) : null,
  );
}
