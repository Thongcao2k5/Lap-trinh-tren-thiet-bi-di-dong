import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrlSafely(BuildContext context, String urlString) async {
  final url = Uri.tryParse(urlString);
  if (url != null) {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở liên kết')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể mở liên kết')));
      }
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Không thể mở liên kết')));
    }
  }
}

Future<void> openMapSafely(BuildContext context, String mapUrl) async {
  final url = Uri.tryParse(mapUrl);
  if (url == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ bản đồ không hợp lệ')),
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!launched) {
      final fallback = await launchUrl(url, mode: LaunchMode.platformDefault);
      if (!fallback && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở Google Maps. Vui lòng thử lại sau.'),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở Google Maps. Vui lòng thử lại sau.'),
        ),
      );
    }
  }
}
