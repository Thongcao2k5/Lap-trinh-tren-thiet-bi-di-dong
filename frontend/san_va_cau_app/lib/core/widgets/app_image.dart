import 'package:flutter/material.dart';
import '../constants/api_config.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String source;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Uploads are served at the backend origin, outside its /api prefix.
  static String? resolveSource(String source, {String? apiBaseUrl}) {
    final value = source.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('assets/')) return value;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme == 'http' || uri.scheme == 'https') return value;
    if (value.startsWith('/uploads/') || value.startsWith('uploads/')) {
      final base = Uri.parse(apiBaseUrl ?? ApiConfig.baseUrl);
      return base.replace(path: '/', query: null, fragment: null)
          .resolve(value).toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveSource(source);
    if (resolved == null) {
      return fallback;
    }

    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
