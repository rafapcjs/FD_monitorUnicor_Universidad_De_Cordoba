import 'dart:async';
import 'dart:developer' as developer;
import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  static StreamSubscription? _linkSubscription;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void initialize() {
    if (kIsWeb) {
      developer.log('Deep links no están soportados en web', name: 'DeepLinkService');
      return;
    }
    
    try {
      _linkSubscription = linkStream.listen(
        (String? link) {
          if (link != null) {
            _handleIncomingLink(link);
          }
        },
        onError: (err) {
          developer.log('Error en deep link: $err', name: 'DeepLinkService');
        },
      );
    } catch (e) {
      developer.log('Error inicializando deep links: $e', name: 'DeepLinkService');
    }
  }

  static void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    
    if (uri.scheme == 'iot' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      
      if (token != null && token.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(
          '/reset-password',
          arguments: {'token': token},
        );
      }
    }
  }

  static Future<String?> getInitialLink() async {
    if (kIsWeb) {
      return null;
    }
    
    try {
      final String? initialLink = await getInitialUri().then((uri) => uri?.toString());
      if (initialLink != null) {
        final uri = Uri.parse(initialLink);
        if (uri.scheme == 'iot' && uri.host == 'reset-password') {
          return uri.queryParameters['token'];
        }
      }
    } catch (e) {
      developer.log('Error obteniendo link inicial: $e', name: 'DeepLinkService');
    }
    return null;
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}