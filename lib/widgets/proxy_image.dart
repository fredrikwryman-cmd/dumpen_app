/// # Proxy-aware CachedNetworkImage-wrapper
library;
///
/// I web-läge när appen körs via serve_web.py behöver alla bild-URL:er
/// som pekar på dumpen.se gå genom proxyn (/proxy/*) för att undvika
/// CORS-blockering. I mobil-läge skickas URL:en direkt.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_config.dart';

/// Returnerar URL:en med proxy-prefix om vi kör i web-länge mot dumpen.se.
String _proxied(String url) => AppConfig.proxyUrl(url);

/// Wrapper runt [CachedNetworkImage] som automatiskt proxar dumpen.se-URL:er.
class ProxyImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = _proxied(imageUrl);
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : null,
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : null,
      // I web-läge behöver vi CORS-tillstånd
      httpHeaders: const {'Accept': '*/*'},
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}
