import 'package:expense_tracker/components/conta_item.dart';
import 'package:expense_tracker/models/conta.dart';
import 'package:expense_tracker/pages/conta_cadastro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/contas_repository.dart';

class ContasPage extends StatefulWidget {
  const ContasPage({super.key});

  @override
  State<ContasPage> createState() => _ContasPageState();
}

class _ContasPageState extends State<ContasPage> {
  final contasRepo = ContasRepository();
  late Future<List<Conta>> futureContas;
  User? user;

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;
    futureContas = contasRepo.listarContas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
      ),
      body: FutureBuilder<List<Conta>>(
        future: futureContas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar contas"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nenhuma conta encontrada"),
            );
          } else {
            final contas = snapshot.data!;
            return ListView.separated(
              itemCount: contas.length,
              itemBuilder: (context, index) { //com o item builder estamos construindo a instancia de UM ITEM, que vai repetir varias vezes para cada um da lista
                final conta = contas[index];
                return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                        onPressed: (context) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContaCadastroPage(
                                contaParaEdicao: conta,
                              ),
                            ),
                          ) as bool?;

                          if (result == true) {
                            setState(() {
                              futureContas =
                                  contasRepo.listarContas();
                            });
                          }
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                        SlidableAction(
                        onPressed: (context) async {
                          await contasRepo.excluirConta(conta.id); //item conta atual

                          setState(() {
                            contas.removeAt(index);
                          });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Remover',
                      )
                      ],
                    ),
                    child: ContaItem(conta: conta));
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "conta-cadastro",
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/conta-cadastro') as bool?;

          if (result == true) {
            setState(() {
              futureContas = contasRepo.listarContas();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
