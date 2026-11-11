import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'cadastro_screen.dart';
import 'navegacao.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    final ok =
    await context.read<AuthProvider>().entrar(_email.text, _senha.text);
    if (ok && mounted) irParaHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.home_repair_service, size: 72, color: cor.primary),
                  const SizedBox(height: 8),
                  Text('ResolveAí',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Serviços domésticos e reparos perto de você',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'E-mail', prefixIcon: Icon(Icons.email)),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Informe um e-mail válido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senha,
                    obscureText: _ocultar,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _ocultar ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                      ),
                    ),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a senha' : null,
                  ),
                  if (auth.erro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(auth.erro!,
                          style: TextStyle(color: cor.error),
                          textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: auth.carregando ? null : _entrar,
                    child: auth.carregando
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Entrar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastroScreen()),
                    ),
                    child: const Text('Não tem conta? Cadastre-se'),
                  ),
                  if (kDebugMode) ...[
                    const Divider(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/dev'),
                      child: const Text('Telas de teste (debug)'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}