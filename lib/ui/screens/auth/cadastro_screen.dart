import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/usuario.dart';
import '../../../providers/auth_provider.dart';
import 'navegacao.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  TipoUsuario _tipo = TipoUsuario.cliente;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().cadastrar(
          nome: _nome.text,
          email: _email.text,
          senha: _senha.text,
          tipo: _tipo,
        );
    if (ok && mounted) irParaHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SegmentedButton<TipoUsuario>(
              segments: const [
                ButtonSegment(
                    value: TipoUsuario.cliente,
                    icon: Icon(Icons.person),
                    label: Text('Sou Cliente')),
                ButtonSegment(
                    value: TipoUsuario.prestador,
                    icon: Icon(Icons.handyman),
                    label: Text('Sou Prestador')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Mínimo de 6 caracteres'
                  : null,
            ),
            if (auth.erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(auth.erro!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.carregando ? null : _cadastrar,
              child: auth.carregando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
