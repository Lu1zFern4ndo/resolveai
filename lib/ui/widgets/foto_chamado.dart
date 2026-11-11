import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/chamado.dart';

class FotoChamado extends StatelessWidget {
  final Chamado chamado;
  final double altura;

  const FotoChamado({super.key, required this.chamado, this.altura = 140});

  @override
  Widget build(BuildContext context) {
    final b64 = chamado.fotoBase64;
    if (b64 != null && b64.isNotEmpty) {
      return Image.memory(
        base64Decode(b64),
        height: altura,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    final path = chamado.fotoPath;
    if (path != null && path.isNotEmpty) {
      return Image.file(
        File(path),
        height: altura,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return const SizedBox.shrink();
  }
}