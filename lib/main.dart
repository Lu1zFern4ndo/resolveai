import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'core/utils/mock_data.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chamado_provider.dart';
import 'providers/foto_provider.dart';
import 'providers/location_provider.dart';
import 'ui/screens/tela_teste_camera.dart';
import 'ui/screens/tela_teste_notificacao.dart';
import 'ui/widgets/mapa_prestadores.dart';
import 'ui/screens/auth/porta_de_entrada.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()..atualizar()),
        ChangeNotifierProvider(create: (_) => ChamadoProvider()),
        ChangeNotifierProvider(create: (_) => FotoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResolveAí',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const PortaDeEntrada(),
      routes: {
        '/dev': (_) => const TelaTeste(),
      },
    );
  }
}

class TelaTeste extends StatelessWidget {
  const TelaTeste({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final proximos = loc.prestadoresProximos(prestadoresMock, raioKm: 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ResolveAí - Teste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaTesteCamera()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaTesteNotificacao()),
            ),
          ),
        ],
      ),
      body: loc.carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posição: ${loc.lat.toStringAsFixed(4)}, ${loc.lng.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(loc.usandoGpsReal
                    ? 'Fonte: GPS real'
                    : 'Fonte: posição reserva (Teresina)'),
                if (loc.erro != null) ...[
                  Text(loc.erro!.mensagem,
                      style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: loc.abrirConfiguracoes,
                    child: const Text('Abrir configurações'),
                  ),
                ],
                TextButton(
                  onPressed: loc.atualizar,
                  child: const Text('Atualizar localização'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: MapaPrestadores(
              centro: LatLng(loc.lat, loc.lng),
              prestadores: proximos,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: proximos.length,
              itemBuilder: (_, i) {
                final p = proximos[i].prestador;
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(p.nome),
                  subtitle: Text(
                    '${p.categoria.nome} • ${proximos[i].distanciaFormatada}',
                  ),
                  trailing: Text('⭐ ${p.avaliacao}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}