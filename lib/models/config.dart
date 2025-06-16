class Config {
  int usuarioId;
  bool lembreteConsulta;
  bool lembreteVacina;
  bool lembreteVermifugo;
  int diasConsulta;
  int diasVacina;
  int diasVermifugo;

  Config({
    required this.usuarioId,
    required this.lembreteConsulta,
    required this.lembreteVacina,
    required this.lembreteVermifugo,
    required this.diasConsulta,
    required this.diasVacina,
    required this.diasVermifugo,
  });

  Map<String, dynamic> toMap() => {
    'usuarioId': usuarioId,
    'lembreteConsulta': lembreteConsulta ? 1 : 0,
    'lembreteVacina': lembreteVacina ? 1 : 0,
    'lembreteVermifugo': lembreteVermifugo ? 1 : 0,
    'diasConsulta': diasConsulta,
    'diasVacina': diasVacina,
    'diasVermifugo': diasVermifugo,
  };

  factory Config.fromMap(Map<String, dynamic> map) => Config(
    usuarioId: map['usuarioId'],
    lembreteConsulta: map['lembreteConsulta'] == 1,
    lembreteVacina: map['lembreteVacina'] == 1,
    lembreteVermifugo: map['lembreteVermifugo'] == 1,
    diasConsulta: map['diasConsulta'],
    diasVacina: map['diasVacina'],
    diasVermifugo: map['diasVermifugo'],
  );
}
