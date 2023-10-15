import 'package:expense_tracker/pages/bancos_select_page.dart';
import 'package:expense_tracker/repository/contas_repository.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../components/banco_select.dart';
import '../models/banco.dart';
import '../models/conta.dart';

class ContaCadastroPage extends StatefulWidget {
  final Conta? contaParaEdicao;
  const ContaCadastroPage({super.key, this.contaParaEdicao});

  @override
  State<ContaCadastroPage> createState() => _ContaCadastroPageState();
}

class _ContaCadastroPageState extends State<ContaCadastroPage> {
  final descricaoController = TextEditingController();
  final contaRepo = ContasRepository();

  final _formKey = GlobalKey<FormState>();

  Banco? bancoSelecionado;
  TipoConta tipoContaSelecionada = TipoConta.contaCorrente;

   @override
  void initState() {
    final conta = widget.contaParaEdicao;

    if (conta != null) {
      descricaoController.text = conta.descricao;
      tipoContaSelecionada = conta.tipoConta;
      bancoSelecionado = bancosMap[conta.bancoId];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Conta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDescricao(),
                const SizedBox(height: 30),
                _buildTipoConta(),
                const SizedBox(height: 30),
                _buildBancoSelect(),
                const SizedBox(height: 30),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BancoSelect _buildBancoSelect() {
    return BancoSelect(
      banco: bancoSelecionado,
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BancosSelectPage(),
          ),
        ) as Banco?;

        if (result != null) {
          setState(() {
            bancoSelecionado = result;
          });
        }
      },
    );
  }

  TextFormField _buildDescricao() {
    return TextFormField(
      controller: descricaoController,
      decoration: const InputDecoration(
        hintText: 'Informe a descrição',
        labelText: 'Descrição',
        prefixIcon: Icon(Ionicons.text_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe uma Descrição';
        }
        if (value.length < 5 || value.length > 30) {
          return 'A Descrição deve entre 5 e 30 caracteres';
        }
        return null;
      },
    );
  }

  DropdownMenu<TipoConta> _buildTipoConta() {
    return DropdownMenu<TipoConta>(
      width: MediaQuery.of(context).size.width - 16,
      initialSelection: tipoContaSelecionada,
      label: const Text('Tipo de Conta'),
      dropdownMenuEntries: const [
        DropdownMenuEntry(
          value: TipoConta.contaCorrente,
          label: "Conta Corrente",
        ),
        DropdownMenuEntry(
          value: TipoConta.contaInvestimento,
          label: "Despesa",
        ),
        DropdownMenuEntry(
          value: TipoConta.contaPoupanca,
          label: "Poupanca",
        ),
      ],
      onSelected: (value) {
        tipoContaSelecionada = value!;
      },
    );
  }

  SizedBox _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            if (bancoSelecionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione um banco.'),
                ),
              );
            } else {
              final bancoId = bancoSelecionado!.id;
              final descricao = descricaoController.text;
              final tipoConta = tipoContaSelecionada;

              final conta = Conta(
                  id: 0,
                  bancoId: bancoId,
                  descricao: descricao,
                  tipoConta: tipoConta);
              // Faça o que você precisa fazer com os dados
              if (widget.contaParaEdicao == null) {
                await _cadastrarConta(conta);
              } else {
                 conta.id = widget.contaParaEdicao!.id;
                 await _alterarConta(conta);
              }
            }
          }
        },
        child: const Text('Cadastrar'),
      ),
    );
  }

  Future<void> _cadastrarConta(Conta conta) async {
   final scaffold = ScaffoldMessenger.of(context);
   await contaRepo.cadastrarConta(conta).then((_){
     scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Conta cadastrada com sucesso',
        ),
      ));
       Navigator.of(context).pop(true);
   }).catchError((error){
     scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Erro ao cadastrar conta',
        ),
      ));
   Navigator.of(context).pop(false);
   
   });
  }

  Future<void> _alterarConta(Conta conta) async {
    final scaffold = ScaffoldMessenger.of(context);
    await contaRepo.alterarConta(conta).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Conta alterada com sucesso',
        ),
      ));
      Navigator.of(context).pop(true);

    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text(
          'Erro ao alterar Conta',
        ),
      ));

      Navigator.of(context).pop(false);
    });
  }
}
