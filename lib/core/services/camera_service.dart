import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum TipoErroCamera { permissaoNegada, cameraIndisponivel, falhaCompressao, desconhecido }

class CameraException implements Exception {
  final TipoErroCamera tipo;
  final String mensagem;
  const CameraException(this.tipo, this.mensagem);

  @override
  String toString() => mensagem;
}

enum OrigemFoto { camera, galeria }

class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<File?> capturar({OrigemFoto origem = OrigemFoto.camera}) async {
    final XFile? foto;
    try {
      foto = await _picker.pickImage(
        source: origem == OrigemFoto.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' ||
          e.code == 'photo_access_denied') {
        throw const CameraException(
          TipoErroCamera.permissaoNegada,
          'Permissão negada. Libere o acesso nas configurações do app.',
        );
      }
      throw const CameraException(
        TipoErroCamera.cameraIndisponivel,
        'Não foi possível abrir a câmera neste aparelho.',
      );
    } catch (_) {
      throw const CameraException(
        TipoErroCamera.desconhecido,
        'Erro inesperado ao capturar a foto.',
      );
    }

    if (foto == null) return null;

    return _comprimir(File(foto.path));
  }

  Future<File> _comprimir(File original) async {
    try {
      final dir = await getTemporaryDirectory();
      final destino =
          '${dir.path}/chamado_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final resultado = await FlutterImageCompress.compressAndGetFile(
        original.absolute.path,
        destino,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );

      return resultado != null ? File(resultado.path) : original;
    } catch (_) {
      throw const CameraException(
        TipoErroCamera.falhaCompressao,
        'Não foi possível processar a imagem.',
      );
    }
  }

  static Future<String> tamanhoLegivel(File arquivo) async {
    final bytes = await arquivo.length();
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<String> salvarPermanente(String caminhoTemporario) async {
    try {
      final origem = File(caminhoTemporario);
      if (!await origem.exists()) return caminhoTemporario;

      final docs = await getApplicationDocumentsDirectory();
      final pasta = Directory(p.join(docs.path, 'chamados'));
      if (!await pasta.exists()) await pasta.create(recursive: true);

      final destino = p.join(pasta.path, p.basename(caminhoTemporario));
      await origem.copy(destino);
      return destino;
    } catch (_) {
      return caminhoTemporario;
    }
  }
}