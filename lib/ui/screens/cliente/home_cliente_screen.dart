import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/models/categoria_servico.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../core/utils/mock_data.dart';
import '../../../providers/location_provider.dart';
import '../../widgets/mapa_prestadores.dart';
import '../perfil/perfil_screen.dart';
import 'novo_chamado_screen.dart';
import 'propostas_screen.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  CategoriaServico? _filtro;

  void _abrirDetalhe(PrestadorComDistancia item) {
    final p = item.prestador;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.nome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${p.categoria.nome} • ${item.distanciaFormatada}'),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(p.avaliacao.toStringAsFixed(1)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.phone, size: 18),
              const SizedBox(width: 4),
              Text(p.telefone),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _bannerErro(LocationProvider loc) {
    return MaterialBanner(
      content: Text(loc.erro!.mensagem),
      leading: const Icon(Icons.location_off),
      actions: [
        TextButton(
          onPressed: loc.abrirConfiguracoes,
          child: const Text('Configurações'),
        ),
        TextButton(
          onPressed: loc.atualizar,
          child: const Text('Tentar de novo'),
        ),
      ],
    );
  }

  Widget _filtros() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: _filtro == null,
              onSelected: (_) => setState(() => _filtro = null),
            ),
          ),
          for (final c in CategoriaServico.values)
            Padding(
              padding: const EdgeInsets.all(6),
              child: ChoiceChip(
                label: Text(c.nome),
                selected: _filtro == c,
                onSelected: (_) => setState(() => _filtro = c),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final todos = loc.prestadoresProximos(prestadoresMock, raioKm: 10);
    final prestadores = _filtro == null
        ? todos
        : todos.where((i) => i.prestador.categoria == _filtro).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ResolveAí'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Atualizar localização',
            onPressed: loc.carregando ? null : loc.atualizar,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Meus chamados',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PropostasScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loc.erro != null) _bannerErro(loc),
          if (loc.carregando) const LinearProgressIndicator(),
          _filtros(),
          Expanded(
            child: MapaPrestadores(
              centro: LatLng(loc.lat, loc.lng),
              prestadores: prestadores,
              aoTocarPrestador: _abrirDetalhe,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novo chamado'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NovoChamadoScreen(lat: loc.lat, lng: loc.lng),
          ),
        ),
      ),
    );
  }
}
