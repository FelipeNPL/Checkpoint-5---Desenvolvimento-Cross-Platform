import 'package:expense_tracker/models/banco.dart';
import 'package:expense_tracker/models/tipo_contato.dart';
import 'package:expense_tracker/pages/bancos_select_page.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/contato.dart'; // Import your Contato model
import 'package:expense_tracker/repository/contatos_repository.dart'; // Import your ContatosRepository
import 'package:supabase_flutter/supabase_flutter.dart';

class ContatoCadastroPage extends StatefulWidget {
  final Contato? contatoParaEdicao;

  const ContatoCadastroPage({super.key, this.contatoParaEdicao});

  @override
  State<ContatoCadastroPage> createState() => _ContatoCadastroPageState();
}

class _ContatoCadastroPageState extends State<ContatoCadastroPage> {
  User? user;
  final contatosRepo = ContatosRepository();

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final notasController = TextEditingController();
  String? bancoIdselecionado = '';

  final _formKey = GlobalKey<FormState>();

  TipoContato tipoContatoSelecionado = TipoContato.corretor; 

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;

    final contato = widget.contatoParaEdicao;

    if (contato != null) {
      nomeController.text = contato.nome;
      telefoneController.text = contato.telefone;
      emailController.text = contato.email;
      tipoContatoSelecionado = contato.tipoContato;
      if (contato.notas != '') {
       notasController.text = contato.notas; 
      }
      if (contato.bancoId != '' || contato.bancoId != null) {
       bancoIdselecionado = contato.bancoId;
      }

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Contato'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNome(),
                const SizedBox(height: 30),
                _buildTipoContato(),
                const SizedBox(height: 30),
                _buildTelefone(),
                const SizedBox(height: 30),
                _buildEmail(),
                const SizedBox(height: 30),
                _buildNotas(),
                const SizedBox(height: 30),
                _buildButton(bancoIdselecionado),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildNome() {
    return TextFormField(
      controller: nomeController,
      decoration: const InputDecoration(
        hintText: 'Informe o nome',
        labelText: 'Nome',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um nome';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<TipoContato> _buildTipoContato() {
    return DropdownButtonFormField<TipoContato>(
      value: tipoContatoSelecionado,
      onChanged: (value) {
        setState(() async {
          tipoContatoSelecionado = value!;
          if (tipoContatoSelecionado != TipoContato.banco) {
            bancoIdselecionado = null; 
          } else {
            Banco bancoSelecionado = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BancosSelectPage(),
          ),
        ) as Banco;
            bancoIdselecionado = bancoSelecionado.id;
          }
        });
      },
      items: TipoContato.values
          .map((tipo) => DropdownMenuItem(
                value: tipo,
                child: Text(tipo.name),
              ))
          .toList(),
      decoration: const InputDecoration(
        hintText: 'Selecione o tipo de contato',
        labelText: 'Tipo de Contato',
        prefixIcon: Icon(Icons.contact_page),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null) {
          return 'Selecione o tipo de contato';
        }
        return null;
      },
    );
  }

  TextFormField _buildTelefone() {
    return TextFormField(
      controller: telefoneController,
      decoration: const InputDecoration(
        hintText: 'Informe o telefone',
        labelText: 'Telefone',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um telefone';
        }
        return null;
      },
    );
  }

  TextFormField _buildEmail() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        hintText: 'Informe o e-mail',
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe um e-mail';
        }
        return null;
      },
    );
  }

  TextFormField _buildNotas() {
    return TextFormField(
      controller: notasController,
      decoration: const InputDecoration(
        hintText: 'Notas do contato',
        labelText: 'Notas',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
    );
  }

  SizedBox _buildButton(String? bancoId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            
            final nome = nomeController.text;
            
            final tipoContato = tipoContatoSelecionado;
            
            final telefone = telefoneController.text;
            
            final email = emailController.text;
            
            final notas = notasController.text;

            final userId = user?.id ?? '';

            final bancoId = bancoIdselecionado;

            final contato = Contato(
              id: 0,
              userId: userId,
              nome: nome,
              telefone: telefone,
              email: email,
              tipoContato: tipoContato,
              notas: notas,
              bancoId: bancoId
            );

            if (widget.contatoParaEdicao == null) {
              await _cadastrarContato(contato);
            } else {
              contato.id = widget.contatoParaEdicao!.id;
              await _alterarContato(contato);
            }
          }
        },
        child: const Text('Cadastrar'),
      ),
    );
  }

  Future<void> _cadastrarContato(Contato contato) async {
    final scaffold = ScaffoldMessenger.of(context);
    await contatosRepo.cadastrarContato(contato).then((_) {
      
      scaffold.showSnackBar(const SnackBar(
        content: Text('Contato cadastrado com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao cadastrar o contato'),
      ));

      Navigator.of(context).pop(false);
    });
  }

  Future<void> _alterarContato(Contato contato) async {
    final scaffold = ScaffoldMessenger.of(context);
    await contatosRepo.alterarContato(contato).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text('Contato alterado com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao alterar o contato'),
      ));

      Navigator.of(context).pop(false);
    });
  }
}
