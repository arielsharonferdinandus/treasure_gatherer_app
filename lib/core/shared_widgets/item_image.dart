import 'dart:convert';
import 'package:flutter/material.dart';

class ItemImage extends StatelessWidget {
  final String source;
  final double? height;
  final double? width;
  final BoxFit fit;
  final IconData placeholderIcon;
  final Color placeholderColor;
  final Color placeholderBackground;
  final BorderRadius? borderRadius;

  const ItemImage({
    super.key,
    required this.source,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.devices,
    this.placeholderColor = const Color(0xFF5DB075),
    this.placeholderBackground = const Color(0x265DB075), // 15% opacity green
    this.borderRadius,
  });

  Widget _placeholder() {
    final box = Container(
      height: height,
      width: width,
      color: placeholderBackground,
      child: Center(
        child: Icon(placeholderIcon, size: (height ?? 90) * 0.44, color: placeholderColor),
      ),
    );
    if (borderRadius == null) return box;
    return ClipRRect(borderRadius: borderRadius!, child: box);
  }

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _placeholder();

    Widget imageWidget;

    if (source.startsWith('data:image')) {
      // Base64 photo captured via camera/gallery.
      try {
        final base64Str = source.split(',').last;
        final bytes = base64Decode(base64Str);
        imageWidget = Image.memory(
          bytes,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    } else {
      // Plain network URL.
      imageWidget = Image.network(
        source,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },
      );
    }

    if (borderRadius == null) return imageWidget;
    return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
  }
}
