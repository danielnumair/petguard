class Usuario {
  int? id;
  String nome;
  String email;
  String senha;

  Usuario({this.id, required this.nome, required this.email, required this.senha});

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'senha': senha,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'],
    nome: map['nome'],
    email: map['email'],
    senha: map['senha'],
  );
}
