import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/models/usuario.dart';

void mostrarPerfilPrestador(BuildContext context, String prestadorId) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
      FirebaseFirestore.instance.collection('usuarios').doc(prestadorId).get(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
              height: 160, child: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data?.data();
        if (data == null) {
          return const SizedBox(
              height: 160,
              child: Center(child: Text('Perfil não encontrado.')));
        }
        final u = Usuario.fromMap({...data, 'id': prestadorId});

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(u.nome.isNotEmpty ? u.nome[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(u.nome,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ]),
              const SizedBox(height: 16),
              if (u.especialidade != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(u.especialidade!.icone,
                      color: u.especialidade!.cor),
                  title: const Text('Especialidade'),
                  subtitle: Text(u.especialidade!.nome),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone),
                title: const Text('Telefone'),
                subtitle: SelectableText(u.telefone ?? 'Não informado'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email),
                title: const Text('E-mail'),
                subtitle: SelectableText(u.email),
              ),
            ],
          ),
        );
      },
    ),
  );
}