import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/categoria_servico.dart';
import '../../../core/models/chamado.dart';
import '../../../core/services/camera_service.dart';
import '../../../providers/chamado_provider.dart';
import '../../../providers/foto_provider.dart';
import '../../widgets/foto_preview.dart';

class NovoChamadoScreen extends StatefulWidget {
  final double lat;
  final double lng;
  const NovoChamadoScreen({super.key, required this.lat, required this.lng});

  @override
  State<NovoChamadoScreen> createState() => _NovoChamadoScreenState();
}

class _NovoChamadoScreenState extends State<NovoChamadoScreen> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  CategoriaServico? _categoria;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_form.currentState!.validate()) return;

    final fotoProv = context.read<FotoProvider>();
    final agora = DateTime.now();

    context.read<ChamadoProvider>().criarChamado(Chamado(
          id: agora.millisecondsSinceEpoch.toString(),
          titulo: _titulo.text.trim(),
          descricao: _descricao.text.trim(),
          categoria: _categoria!,
          lat: widget.lat,
          lng: widget.lng,
          criadoEm: agora,
          fotoPath: fotoProv.foto?.path,
        ));

    // Limpa para o próximo chamado. ATENÇÃO: se o remover() do FotoProvider
    // apagar o arquivo do disco, a foto do chamado quebra (ver observações).
    fotoProv.remover();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Chamado enviado!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fotoProv = context.watch<FotoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo chamado')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricao,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: 'Descreva o problema'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CategoriaServico>(
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: CategoriaServico.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v),
              validator: (v) => v == null ? 'Escolha uma categoria' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: fotoProv.carregando
                        ? null
                        : () => fotoProv.capturar(OrigemFoto.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tirar foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: fotoProv.carregando
                        ? null
                        : () => fotoProv.capturar(OrigemFoto.galeria),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
            if (fotoProv.carregando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (fotoProv.erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(fotoProv.erro!.mensagem,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (fotoProv.foto != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FotoPreview(
                  arquivo: fotoProv.foto!,
                  tamanho: fotoProv.tamanho.toString(),
                  onRemover: fotoProv.remover,
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _enviar, child: const Text('Enviar chamado')),
          ],
        ),
      ),
    );
  }
}
