import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketConfig {
  // URL del WebSocket desde variables de entorno
  static String get currentUrl {
    // Intenta obtener NODE_WEBSOCKET_URL primero, si no está disponible usa WEBSOCKET_URL
    final url = dotenv.env['NODE_WEBSOCKET_URL'] ??
                dotenv.env['WEBSOCKET_URL'] ??
                'http://localhost:3000';
    return url;
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration reconnectionDelay = Duration(seconds: 2);
  static const int maxReconnectionAttempts = 5;

  // Eventos
  static const String eventAuthenticate = 'authenticate';
  static const String eventAuthenticated = 'authenticated';
  static const String eventAuthenticationError = 'authentication_error';

  // Eventos de Proformas
  static const String eventProformaCreated = 'proforma_created_confirmation';
  static const String eventProformaApproved = 'proforma_approved';
  static const String eventProformaRejected = 'proforma_rejected';
  static const String eventProformaConverted = 'proforma_converted_to_sale';

  // Eventos de Stock
  static const String eventStockReserved = 'stock_reserved';
  static const String eventStockExpiring = 'stock_reservation_expiring';
  static const String eventStockUpdated = 'product_stock_updated';

  // Eventos de Pagos
  static const String eventPaymentConfirmed = 'payment_confirmed';

  // Eventos del Sistema
  static const String eventConnect = 'connect';
  static const String eventDisconnect = 'disconnect';
  static const String eventError = 'error';
  static const String eventServerShutdown = 'server_shutdown';
}
