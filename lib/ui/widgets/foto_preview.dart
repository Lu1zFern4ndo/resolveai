import 'dart:io';
import 'package:flutter/material.dart';

class FotoPreview extends StatelessWidget {
  final File arquivo;
  final String tamanho;
  final VoidCallback onRemover;

  const FotoPreview({
    super.key,
    required this.arquivo,
    required this.tamanho,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(arquivo,
                  height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.close),
              onPressed: onRemover,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Tamanho: $tamanho', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
