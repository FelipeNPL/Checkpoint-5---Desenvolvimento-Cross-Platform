import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tipo_contato.dart';
import '../models/contato.dart';

class ContatosRepository {
  Future<List<Contato>> listarContatos({required String userId, TipoContato? tipoContato}) async {
    final supabase = Supabase.instance.client;

    var query = 
    supabase.from('contatos').select<List<Map<String, dynamic>>>('''
            *
            ''').eq('user_id', userId);

    if (tipoContato != null) {
      query = query.eq('tipo_contato', tipoContato.index);
    }

    var data = await query;

    final list = data.map((map) {
      return Contato.fromMap(map);
    }).toList();

    return list;
  }

  Future cadastrarContato(Contato contato) async {
    final supabase = Supabase.instance.client;

    await supabase.from('contatos').insert({
      'user_id': contato.userId,
      'nome': contato.nome,
      'telefone': contato.telefone,
      'email': contato.email,
      'tipo_contato': contato.tipoContato.index,
      'notas': contato.notas,
      'banco_id': contato.bancoId
    });
  }

  Future alterarContato(Contato contato) async {
    final supabase = Supabase.instance.client;

    await supabase.from('contatos').update({
      'nome': contato.nome,
      'telefone': contato.telefone,
      'email': contato.email,
      'tipo_contato': contato.tipoContato.index,
      'notas': contato.notas,
      'banco_id': contato.bancoId
    }).match({'id': contato.id});
  }

  Future excluirContato(int id) async {
    final supabase = Supabase.instance.client;

    await supabase.from('contatos').delete().match({'id': id});
  }
}
