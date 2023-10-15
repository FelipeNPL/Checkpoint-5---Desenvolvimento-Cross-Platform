import 'package:expense_tracker/models/tipo_contato.dart';

class Contato {
  int id;
  String userId;
  String nome;
  String telefone;
  String email;
  String notas;
  String? bancoId;
  TipoContato tipoContato;

  Contato({
    required this.id,
    required this.userId,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.tipoContato,
    this.bancoId = '',
    this.notas = '',
  });

  factory Contato.fromMap(Map<String, dynamic> map) {
    return Contato(
      id: map['id'],
      userId: map['user_id'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      tipoContato: TipoContato.values[map['tipo_contato']],
      notas: map['notas'],
      bancoId: map['banco_id'],
    );
  }
}
