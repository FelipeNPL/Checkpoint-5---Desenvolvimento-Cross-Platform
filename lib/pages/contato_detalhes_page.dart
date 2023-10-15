import 'package:expense_tracker/models/banco.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/tipo_contato.dart';
import '../models/contato.dart';

class ContatoDetalhesPage extends StatefulWidget {
  const ContatoDetalhesPage({Key? key}) : super(key: key);

  @override
  State<ContatoDetalhesPage> createState() => _ContatoDetalhesPageState();
}

class _ContatoDetalhesPageState extends State<ContatoDetalhesPage> {
  @override
  Widget build(BuildContext context) {
    final contato = ModalRoute.of(context)!.settings.arguments as Contato;

    return Scaffold(
      appBar: AppBar(
        title: Text(contato.nome),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Tipo de Contato", getTipoContatoLabel(contato.tipoContato,
                bancoName: contato.tipoContato == TipoContato.banco ? bancosMap[contato.bancoId]?.nome : null)),
            _buildDivider(),
            _buildDetailRow("Telefone", contato.telefone),
            _buildDivider(),
            _buildDetailRow("E-mail", contato.email),
            _buildDivider(),
            _buildDetailRow("Notas", contato.notas.isEmpty ? '-' : contato.notas),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Colors.grey,
    );
  }

  String getTipoContatoLabel(TipoContato tipoContato, {String? bancoName}) {
    if (tipoContato == TipoContato.banco && bancoName != null) {
      return 'Banco: $bancoName';
    }

    switch (tipoContato) {
      case TipoContato.corretor:
        return 'Corretor';
      case TipoContato.consultor:
        return 'Consultor';
      case TipoContato.banco:
        return 'Banco';
      case TipoContato.outros:
        return 'Outros';
      default:
        return 'Desconhecido';
    }
  }
}
