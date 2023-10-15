import 'package:expense_tracker/models/banco.dart';
import 'package:expense_tracker/models/contato.dart';
import 'package:expense_tracker/models/tipo_contato.dart';
import 'package:flutter/material.dart';

class ContatoItem extends StatelessWidget {
  final Contato contato;
  final void Function()? onTap;

  const ContatoItem({Key? key, required this.contato, this.onTap})
      : super(key: key);

  CircleAvatar _getContactAvatar(Contato contato) {
    if (contato.tipoContato == TipoContato.corretor ||
        contato.tipoContato == TipoContato.consultor) {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 15,
        child: Text(
          contato.nome.isNotEmpty ? contato.nome[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    } else if (contato.tipoContato == TipoContato.banco) {
      String bancoImage = bancosMap[contato.bancoId]?.logo ?? '';
      return CircleAvatar(
        radius: 15,
        backgroundImage: AssetImage('images/$bancoImage'),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.black,
        radius: 15,
        child: Icon(Icons.person, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getContactAvatar(contato),
      title: Text(contato.nome),
      subtitle: Text("Telefone: ${contato.telefone}"),
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back,
            size: 15,
          ),
          Text("arraste")
        ],
      ),
      onTap: onTap,
    );
  }
}
