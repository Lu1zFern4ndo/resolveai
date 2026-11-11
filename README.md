# ResolveAí

Aplicativo Flutter que conecta clientes a prestadores de serviços domésticos
(encanadores, eletricistas, pedreiros, técnicos). O cliente abre um chamado
com foto e localização, e os prestadores da especialidade enviam propostas.
Trabalho final de Programação para Dispositivos Móveis, UESPI.

## Recursos implementados

- **Geolocalização** (`geolocator`): posição do usuário, distância e filtro de prestadores por raio ajustável
- **Mapa** (`google_maps_flutter`): prestadores e local do chamado como marcadores
- **Câmera** (`image_picker` + `flutter_image_compress`): foto do problema, com compressão
- **Notificações locais** (`flutter_local_notifications`): aviso ao cliente quando chega uma proposta
- **Firebase Authentication**: cadastro e login reais, com sessão persistente
- **Cloud Firestore**: chamados, propostas e perfis sincronizados em tempo real
- **Foto na nuvem**: imagem comprimida guardada em base64 no documento do chamado

## Como rodar

1. Instale o Flutter e rode `flutter doctor`
2. Clone o repositório e rode `flutter pub get`
3. Crie uma chave do **Maps SDK for Android** no Google Cloud
4. No arquivo `android/local.properties` (não versionado), adicione:

   ```properties
   MAPS_API_KEY=SUA_CHAVE_AQUI
   ```

5. Rode `flutter run` com um celular ou emulador Android

Se a chave estiver restrita por pacote e SHA-1, cada desenvolvedor deve rodar
`cd android; ./gradlew signingReport` e adicionar o próprio SHA-1 à chave no
Google Cloud. Sem isso, o mapa fica cinza.

### Firebase

O projeto usa `lib/firebase_options.dart` e `android/app/google-services.json`.
Para usar outro projeto Firebase, rode `flutterfire configure`, ative
**Authentication (e-mail/senha)** e **Firestore**, e publique as regras de
segurança descritas abaixo.

## Como usar o app

1. **Cadastre-se** como Cliente ou Prestador (o prestador informa telefone e especialidade)
2. **Cliente:** veja prestadores no mapa, abra um chamado com foto e acompanhe as propostas em "Meus chamados"
3. **Prestador:** veja os chamados da sua especialidade (com foto, mapa e distância) e envie propostas
4. O cliente recebe uma **notificação** quando chega proposta e pode aceitá-la

Para ver a notificação em tempo real, use dois aparelhos (cliente em um, prestador em outro).

## Estrutura

```
lib/
├── core/
│   ├── models/     Usuario, Prestador, Chamado, Proposta, CategoriaServico
│   ├── services/   LocationService, CameraService, NotificationService
│   └── utils/      distance_utils, mock_data
├── providers/      AuthProvider, LocationProvider, ChamadoProvider, FotoProvider
└── ui/
    ├── screens/    auth, cliente, prestador, perfil
    └── widgets/    MapaPrestadores, MapaChamado, FotoChamado, FotoPreview
test/               testes de distância, filtro e models
```

## Regras do Firestore

- `usuarios`: leitura e escrita apenas do próprio usuário
- `chamados`: leitura para usuários logados; criação só com `clienteId` igual ao próprio uid
- `propostas`: leitura, criação e atualização para usuários logados; sem exclusão

## Testes

```bash
flutter test
```

Cobrem cálculo de distância, filtro por raio, ordenação e serialização dos models.

## Observações técnicas

- `permission_handler` foi removido por exigir `compileSdk` 37, incompatível com o
  Android Gradle Plugin 9.1. Cada pacote pede a própria permissão.
- `flutter_local_notifications` está fixado na versão 22.3.2, pois a 23 também exige `compileSdk` 37.
- O Firebase Storage exige plano pago em projetos novos; por isso a foto (comprimida a ~800 px) é guardada em base64 no Firestore, respeitando o limite de 1 MB por documento.
- As notificações são locais: funcionam com o app aberto ou em segundo plano. Com o app totalmente fechado, seria necessário FCM com Cloud Functions.
- Prestadores do `mock_data.dart` (Teresina-PI) aparecem no mapa do cliente como dados de demonstração.

## Autores

Trabalho desenvolvido na UESPI, curso de Bacharelado em Ciência da Computação.
