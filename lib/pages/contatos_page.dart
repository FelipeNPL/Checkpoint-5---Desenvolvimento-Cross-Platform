import 'package:expense_tracker/components/contato_item.dart';
import 'package:expense_tracker/models/contato.dart';
import 'package:expense_tracker/pages/contato_cadastro_page.dart';
import 'package:expense_tracker/repository/contatos_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expense_tracker/models/tipo_contato.dart';

class ContatosPage extends StatefulWidget {
  const ContatosPage({Key? key}) : super(key: key);

  @override
  State<ContatosPage> createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  final contatoRepo = ContatosRepository();
  late Future<List<Contato>> futureContatos;
  User? user;

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;
    futureContatos = contatoRepo.listarContatos(userId: user?.id ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos Financeiros'),
        actions: [
          // create a filter menu action
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('Todos'),
                  onTap: () {
                    setState(() {
                      futureContatos = contatoRepo.listarContatos(
                          userId: user?.id ?? '');
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Corretores'),
                  onTap: () {
                    setState(() {
                      futureContatos = contatoRepo.listarContatos(
                          userId: user?.id ?? '',
                          tipoContato: TipoContato.corretor);
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Consultores'),
                  onTap: () {
                    setState(() {
                      futureContatos = contatoRepo.listarContatos(
                          userId: user?.id ?? '',
                          tipoContato: TipoContato.consultor);
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Bancos'),
                  onTap: () {
                    setState(() {
                      futureContatos = contatoRepo.listarContatos(
                          userId: user?.id ?? '',
                          tipoContato: TipoContato.banco);
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Outros'),
                  onTap: () {
                    setState(() {
                      futureContatos = contatoRepo.listarContatos(
                          userId: user?.id ?? '',
                          tipoContato: TipoContato.outros);
                    });
                  },
                )
              ];
            },
          ),
        
        ],
      ),
      body: FutureBuilder<List<Contato>>(
        future: futureContatos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar os contatos"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nenhum contato cadastrado"),
            );
          } else {
            final contatos = snapshot.data!;
            return Card(
               margin: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: contatos.length,
                itemBuilder: (context, index) {
                  final contato = contatos[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContatoCadastroPage(
                                  contatoParaEdicao: contato,
                                ),
                              ),
                            ) as bool?;
            
                            if (result == true) {
                              setState(() {
                                futureContatos = contatoRepo.listarContatos(
                                  userId: user?.id ?? '',
                                );
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
                            await contatoRepo.excluirContato(contato.id);
            
                            setState(() {
                              contatos.removeAt(index);
                            });
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Remover',
                        ),
                      ],
                    ),
                    child: ContatoItem(
                      contato: contato,
                      onTap: () {
                        Navigator.pushNamed(context, '/contato-detalhes',
                            arguments: contato);
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "contato-cadastro",
        shape: const CircleBorder(eccentricity: 0.0),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/contato-cadastro') as bool?;

          if (result == true) {
            setState(() {
              futureContatos = contatoRepo.listarContatos(
                userId: user?.id ?? '',
              );
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
