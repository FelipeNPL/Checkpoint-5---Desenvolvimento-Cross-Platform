class Conta {
   int id;
   String bancoId;
   String descricao;
   TipoConta tipoConta;

  Conta(
      {required this.id,
      required this.bancoId,
      required this.descricao,
      required this.tipoConta});

  factory Conta.fromMap(Map<String, dynamic> map) {
    return Conta(
      id: map['id'],
      bancoId: map['banco'],
      descricao: map['descricao'],
      tipoConta: TipoConta.values[map['tipo_conta']],
    );
  }
}

enum TipoConta { contaCorrente, contaPoupanca, contaInvestimento }
