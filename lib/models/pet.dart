class Pet {
  int? id;
  String nome;
  String especie;
  String raca;
  String sexo;
  DateTime? dataNascimento;
  String observacoes;
  int usuarioId;

  Pet({
    this.id,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.sexo,
    this.dataNascimento,
    required this.observacoes,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'sexo': sexo,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'observacoes': observacoes,
      'usuarioId': usuarioId,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      nome: map['nome'],
      especie: map['especie'],
      raca: map['raca'],
      sexo: map['sexo'],
      dataNascimento: map['dataNascimento'] != null ? DateTime.parse(map['dataNascimento']) : null,
      observacoes: map['observacoes'],
      usuarioId: map['usuarioId'],
    );
  }
}