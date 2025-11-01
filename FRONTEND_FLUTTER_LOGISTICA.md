# 📱 ARQUITECTURA FRONTEND FLUTTER - MÓDULO LOGÍSTICA

**Versión:** 2.0
**Fecha de actualización:** 31 de Octubre de 2025
**Plataforma:** Flutter 3.x + Dart
**Gestores:** Gestor de Flutter
**Estado:** ✅ Fase 1 completada (Cliente), ❌ Fase 3 (Chofer) no iniciada

---

## 📋 ÍNDICE

1. [Visión General](#visión-general)
2. [Roles y Responsabilidades](#roles-y-responsabilidades)
3. [Estado Actual (Octubre 31, 2025)](#estado-actual)
4. [Estructura de Directorios](#estructura-de-directorios)
5. [Modelos de Datos](#modelos-de-datos)
6. [Servicios y Providers](#servicios-y-providers)
7. [Screens por Rol](#screens-por-rol)
8. [Sistema de Tracking GPS](#sistema-de-tracking-gps)
9. [Integración WebSocket](#integración-websocket)
10. [Flujos Principales](#flujos-principales)
11. [Checklist de Implementación](#checklist-de-implementación)

---

## 1. VISIÓN GENERAL

### 1.1 Alcance de Flutter

Flutter cubre **dos roles** en la aplicación:

#### ROL 1: CLIENTE
- Ver catálogo de productos
- Crear proformas/pedidos
- Ver historial de pedidos
- **Tracking en tiempo real** del pedido hasta casa
- Recibir notificaciones de estado

#### ROL 2: CHOFER (NUEVA)
- Ver entregas asignadas del día
- Actualizar estado de entrega
- Enviar ubicación GPS en tiempo real
- Confirmar entrega con firma digital y fotos
- Reportar novedades/problemas
- **NUEVO: Crear clientes** (el chofer puede registrar nuevos clientes en ruta)

### 1.2 Usuarios Finales

- **Clientes:** Personas que compran productos (cientos)
- **Choferes:** Personal de logística que entrega (10-20 personas)
- **Gestor de Flutter:** Responsable de mantener el código y releases

---

## 2. ROLES Y RESPONSABILIDADES

### 2.1 Flujo por Rol

```
┌─────────────────────────────────────────────────┐
│           LOGIN (Misma App para ambos)           │
│         (Detecta rol del usuario)                │
└─────────────────────────────────────────────────┘
          │
          ├─────────────────┬─────────────────┐
          │                 │                 │
       CLIENTE            CHOFER          ADMIN
          │                 │              (futuro)
          ↓                 ↓
    ┌─────────────┐  ┌────────────────┐
    │HomeCliente  │  │HomeChofer      │
    │ BottomNav   │  │ BottomNav      │
    │ - Catálogo  │  │ - Entregas Hoy │
    │ - Carrito   │  │ - Historial    │
    │ - Pedidos   │  │ - Perfil       │
    │ - Tracking  │  │ - Chat(futuro) │
    │ - Perfil    │  │                │
    └─────────────┘  └────────────────┘
```

---

## 3. ESTADO ACTUAL (Octubre 31, 2025)

### 3.1 ROL CLIENTE - Estado ✅ 98% LISTO

| Componente | Estado | % | Detalles |
|-----------|--------|---|----------|
| Models | ✅ | 100% | Pedido, PedidoItem, EstadoPedido, etc. existen |
| Services | ✅ | 100% | PedidoService, TrackingService, etc. existen |
| Providers | ✅ | 100% | CarritoProvider, PedidoProvider, TrackingProvider |
| Screens | ✅ | 100% | Carrito, Pedidos, Tracking, Detalle, etc. |
| WebSocket | ⚠️ | 70% | WebSocketService existe, necesita integración completa |
| Notificaciones | ❌ | 0% | Firebase Messaging NO instalado |
| **TOTAL** | ✅ | **98%** | **Listo para QA** |

### 3.2 ROL CHOFER - Estado ❌ 0% (NO INICIADO)

| Componente | Estado | % | Prioridad |
|-----------|--------|---|-----------|
| Models (Entrega, Chofer, Camion) | ⚠️ | 50% | Chofer, Camion existen; falta Entrega |
| ChoferService | ❌ | 0% | 🔴 CRÍTICO |
| ChoferProvider | ❌ | 0% | 🔴 CRÍTICO |
| Screens | ❌ | 0% | ❌ 5+ screens falta |
| Tracking GPS | ⚠️ | 50% | geolocator instalado, lógica falta |
| Firma Digital | ❌ | 0% | image_picker + signature_pad instalados |
| **TOTAL** | ❌ | **10%** | **CRÍTICO - Fase 3 no iniciada** |

### 3.3 Archivos Existentes (Fase 1 Cliente)

```
lib/
├── models/
│   ├── carrito.dart ✅
│   ├── carrito_item.dart ✅
│   ├── chofer.dart ✅ (existe pero incompleto)
│   ├── camion.dart ✅ (existe pero incompleto)
│   ├── estado_pedido.dart ✅
│   ├── pedido.dart ✅
│   ├── pedido_item.dart ✅
│   ├── pedido_estado_historial.dart ✅
│   ├── ubicacion_tracking.dart ✅
│   ├── reserva_stock.dart ✅
│   └── ... otros
│
├── services/
│   ├── api_service.dart ✅
│   ├── auth_service.dart ✅
│   ├── carrito_service.dart (verificar)
│   ├── pedido_service.dart ✅ (~8KB)
│   ├── tracking_service.dart ✅ (~5KB)
│   ├── websocket_service.dart ✅ (~11KB)
│   └── proforma_service.dart ✅ (~7KB)
│
├── providers/
│   ├── auth_provider.dart ✅
│   ├── carrito_provider.dart ✅
│   ├── pedido_provider.dart ✅
│   ├── tracking_provider.dart ✅
│   └── product_provider.dart ✅
│
└── screens/
    ├── carrito/
    │   └── carrito_screen.dart ✅
    ├── cliente/
    │   └── home_cliente_screen.dart ✅
    ├── pedidos/
    │   ├── direccion_entrega_seleccion_screen.dart ✅
    │   ├── fecha_hora_entrega_screen.dart ✅
    │   ├── pedido_creado_screen.dart ✅
    │   ├── pedido_detalle_screen.dart ✅
    │   ├── pedido_tracking_screen.dart ✅
    │   ├── pedidos_historial_screen.dart ✅
    │   └── resumen_pedido_screen.dart ✅
    └── ... otros
```

---

## 4. ESTRUCTURA DE DIRECTORIOS (Propuesta)

### 4.1 Estructura Completa (Final)

```
lib/
├── main.dart
├── config/
│   ├── websocket_config.dart ✅
│   └── app_config.dart
│
├── models/
│   ├── pedido.dart ✅
│   ├── carrito.dart ✅
│   ├── chofer.dart ⚠️ (EXPANDIR)
│   ├── camion.dart ⚠️ (EXPANDIR)
│   ├── entrega.dart ❌ CREAR
│   ├── ubicacion_tracking.dart ✅
│   ├── user.dart ✅
│   └── ... (6 modelos más existentes)
│
├── services/
│   ├── api_service.dart ✅
│   ├── auth_service.dart ✅
│   ├── pedido_service.dart ✅
│   ├── chofer_service.dart ❌ CREAR
│   ├── tracking_service.dart ✅
│   ├── websocket_service.dart ✅
│   ├── geolocation_service.dart ❌ CREAR
│   └── file_service.dart (para firma + fotos)
│
├── providers/
│   ├── auth_provider.dart ✅
│   ├── carrito_provider.dart ✅
│   ├── pedido_provider.dart ✅
│   ├── chofer_provider.dart ❌ CREAR
│   ├── tracking_provider.dart ✅
│   ├── notification_provider.dart ❌ CREAR
│   └── location_provider.dart ❌ CREAR
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart ✅
│   │   └── role_selector_screen.dart (si aplica)
│   │
│   ├── cliente/
│   │   ├── home_cliente_screen.dart ✅
│   │   ├── carrito/
│   │   │   └── carrito_screen.dart ✅
│   │   ├── pedidos/
│   │   │   ├── pedidos_historial_screen.dart ✅
│   │   │   ├── pedido_detalle_screen.dart ✅
│   │   │   ├── pedido_tracking_screen.dart ✅
│   │   │   ├── direccion_entrega_seleccion_screen.dart ✅
│   │   │   ├── fecha_hora_entrega_screen.dart ✅
│   │   │   └── resumen_pedido_screen.dart ✅
│   │   └── perfil/
│   │       └── perfil_cliente_screen.dart
│   │
│   ├── chofer/
│   │   ├── home_chofer_screen.dart ❌ CREAR
│   │   ├── entregas/
│   │   │   ├── entregas_asignadas_screen.dart ❌ CREAR
│   │   │   ├── entrega_detalle_screen.dart ❌ CREAR
│   │   │   ├── mapa_navegacion_screen.dart ❌ CREAR
│   │   │   ├── firma_digital_screen.dart ❌ CREAR
│   │   │   ├── reportar_novedad_screen.dart ❌ CREAR
│   │   │   └── entrega_completada_screen.dart ❌ CREAR
│   │   ├── clientes/
│   │   │   ├── crear_cliente_screen.dart ❌ CREAR (NUEVO)
│   │   │   └── listar_clientes_screen.dart (FUTURO)
│   │   ├── historial/
│   │   │   └── historial_entregas_screen.dart ❌ CREAR
│   │   └── perfil/
│   │       └── perfil_chofer_screen.dart ❌ CREAR
│   │
│   └── common/
│       ├── splash_screen.dart
│       └── error_screen.dart
│
├── widgets/
│   ├── estado_badge.dart ✅
│   ├── carrito_item_card.dart ✅
│   ├── pedido_card.dart ✅
│   ├── entrega_card.dart ❌ CREAR
│   ├── chofer_info_card.dart ❌ CREAR
│   ├── location_permission_dialog.dart ❌ CREAR
│   ├── firma_preview_widget.dart ❌ CREAR
│   └── custom_app_bar.dart
│
└── utils/
    ├── date_utils.dart
    ├── currency_formatter.dart
    ├── validators.dart
    └── constants.dart
```

---

## 5. MODELOS DE DATOS

### 5.1 Modelos Existentes ✅

Todos los modelos del cliente ya existen. Verificar:
- `pedido.dart`
- `carrito.dart`
- `ubicacion_tracking.dart`
- `chofer.dart` (necesita expansión)
- `camion.dart` (necesita expansión)

### 5.2 Modelo FALTANTE: Entrega ❌ CREAR

```dart
// lib/models/entrega.dart

class Entrega {
  final int id;
  final int proformaId;
  final Pedido? pedido;

  final int? choferId;
  final Chofer? chofer;

  final int? camionId;
  final Camion? camion;

  final int? direccionEntregaId;
  final String? direccionEntrega;
  final double? latitudDestino;
  final double? longitudDestino;

  // Estados
  final EstadoEntrega estado;

  // Tiempos
  final DateTime? fechaAsignacion;
  final DateTime? fechaInicio;        // Cuando chofer inicia ruta
  final DateTime? fechaLlegada;       // Cuando chofer llega
  final DateTime? fechaEntrega;       // Cuando se completa

  // Ubicación actual
  final UbicacionTracking? ubicacionActual;
  final double? etaMinutos;           // Tiempo estimado de llegada

  // Datos de entrega
  final String? observaciones;
  final String? motivoNovedad;
  final String? firmaDigitalUrl;
  final List<String>? fotosEntregaUrls;

  Entrega({
    required this.id,
    required this.proformaId,
    this.pedido,
    this.choferId,
    this.chofer,
    this.camionId,
    this.camion,
    this.direccionEntregaId,
    this.direccionEntrega,
    this.latitudDestino,
    this.longitudDestino,
    required this.estado,
    this.fechaAsignacion,
    this.fechaInicio,
    this.fechaLlegada,
    this.fechaEntrega,
    this.ubicacionActual,
    this.etaMinutos,
    this.observaciones,
    this.motivoNovedad,
    this.firmaDigitalUrl,
    this.fotosEntregaUrls,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      id: json['id'],
      proformaId: json['proforma_id'],
      pedido: json['pedido'] != null ? Pedido.fromJson(json['pedido']) : null,
      choferId: json['chofer_id'],
      chofer: json['chofer'] != null ? Chofer.fromJson(json['chofer']) : null,
      // ... resto de mapping
    );
  }
}

enum EstadoEntrega {
  ASIGNADA,
  EN_CAMINO,
  LLEGO,
  ENTREGADO,
  NOVEDAD,
  CANCELADA,
}
```

### 5.3 Modelos a Expandir ⚠️

#### Chofer (Expandir)
```dart
// lib/models/chofer.dart

class Chofer {
  final int id;
  final int userId;
  final User? user;

  final String nombres;
  final String apellidos;
  final String ci;
  final String telefono;

  final String? licenciaConducir;
  final String? categoriaLicencia;
  final DateTime? fechaVencimientoLicencia;
  final String? fotoUrl;

  final bool activo;
  final DateTime? fechaContratacion;

  // ADICIONALES
  final bool? disponible;          // Disponible para nuevas entregas
  final int? entregasHoy;          // Contador del día
  final double? calificacion;      // Promedio de calificación

  // ... resto
}
```

#### Camion (Expandir)
```dart
// lib/models/camion.dart

class Camion {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final int? anio;
  final String? color;

  final double? capacidadKg;
  final double? capacidadM3;
  final String? fotoUrl;

  final bool activo;
  final DateTime? fechaRevisionTecnica;
  final String? observaciones;

  // ADICIONALES
  final bool? disponible;          // Disponible para nuevas entregas
  final int? entregasHoy;          // Contador del día

  // ... resto
}
```

---

## 6. SERVICIOS Y PROVIDERS

### 6.1 ChoferService ❌ CREAR

```dart
// lib/services/chofer_service.dart

class ChoferService {
  final ApiService _apiService;

  // ENTREGAS
  Future<List<Entrega>> getEntregasAsignadas({
    DateTime? fecha,
    EstadoEntrega? estado,
  }) async {
    // GET /api/chofer/entregas
    // Retornar lista de entregas del chofer para hoy
  }

  Future<Entrega> getEntrega(int id) async {
    // GET /api/chofer/entregas/{id}
  }

  // ACCIONES DE ENTREGA
  Future<void> iniciarRuta(int entregaId) async {
    // POST /api/chofer/entregas/{id}/iniciar-ruta
  }

  Future<void> actualizarEstado(
    int entregaId,
    EstadoEntrega nuevoEstado, {
    String? observaciones,
    String? motivoNovedad,
  }) async {
    // POST /api/chofer/entregas/{id}/actualizar-estado
  }

  Future<void> marcarLlegada(int entregaId) async {
    // POST /api/chofer/entregas/{id}/marcar-llegada
  }

  Future<void> confirmarEntrega(
    int entregaId, {
    required Uint8List firmaBytes,
    List<File>? fotos,
    String? observaciones,
  }) async {
    // POST /api/chofer/entregas/{id}/confirmar-entrega
    // multipart con firma + fotos
  }

  Future<void> reportarNovedad(
    int entregaId, {
    required String motivo,
    String? descripcion,
    List<File>? fotos,
  }) async {
    // POST /api/chofer/entregas/{id}/reportar-novedad
  }

  // UBICACIÓN GPS
  Future<void> enviarUbicacion(
    int entregaId, {
    required double latitud,
    required double longitud,
    double? altitud,
    double? precision,
    double? velocidad,
    double? rumbo,
    String? evento,
  }) async {
    // POST /api/chofer/entregas/{id}/ubicacion
  }

  // HISTORIAL
  Future<List<Entrega>> getHistorialEntregas({
    int page = 1,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    // GET /api/chofer/historial
  }

  // CLIENTES (NUEVO: chofer puede crear)
  Future<Client> crearCliente({
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    // POST /api/chofer/clientes
    // Permitir al chofer registrar nuevos clientes en ruta
  }
}
```

### 6.2 GeolocationService ❌ CREAR

```dart
// lib/services/geolocation_service.dart

class GeolocationService {
  final Geolocator _geolocator = Geolocator();

  Future<bool> requestPermission() async {
    // Solicitar permisos de ubicación (background)
  }

  Future<Position> getCurrentPosition() async {
    // Obtener ubicación actual
  }

  Stream<Position> getPositionStream({
    Duration interval = const Duration(seconds: 15),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    // Stream de actualizaciones de posición
    // Para tracking en tiempo real
  }

  Future<double> calculateDistance(
    double lat1, double lng1, double lat2, double lng2
  ) async {
    // Calcular distancia entre dos puntos
  }

  Future<Map<String, dynamic>> getAddressFromCoordinates(
    double latitude, double longitude
  ) async {
    // Usar geocoding para obtener dirección desde coords
  }
}
```

### 6.3 ChoferProvider ❌ CREAR

```dart
// lib/providers/chofer_provider.dart

class ChoferProvider extends ChangeNotifier {
  final ChoferService _choferService;
  final GeolocationService _geolocService;

  // Estado
  List<Entrega> _entregasAsignadas = [];
  Entrega? _entregaActual;
  bool _isLoading = false;
  bool _compartiendoUbicacion = false;
  Timer? _ubicacionTimer;
  StreamSubscription<Position>? _positionSubscription;

  // ENTREGAS
  Future<void> loadEntregasDelDia() async {
    _isLoading = true;
    try {
      _entregasAsignadas = await _choforService.getEntregasAsignadas();
      notifyListeners();
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadEntrega(int id) async {
    _entregaActual = await _choforService.getEntrega(id);
    notifyListeners();
  }

  // INICIAR RUTA Y TRACKING
  Future<void> iniciarRuta(int entregaId) async {
    await _choforService.iniciarRuta(entregaId);
    _entregaActual?.estado = EstadoEntrega.EN_CAMINO;
    iniciarCompartirUbicacion(entregaId);
    notifyListeners();
  }

  void iniciarCompartirUbicacion(int entregaId) {
    // Iniciar envío automático de ubicación cada 15-30 segundos
    _compartiendoUbicacion = true;

    // Opción 1: Timer simple
    _ubicacionTimer = Timer.periodic(Duration(seconds: 15), (_) async {
      await enviarUbicacionActual(entregaId);
    });

    // Opción 2: Stream (más eficiente)
    _positionSubscription = _geolocService
        .getPositionStream(interval: Duration(seconds: 15))
        .listen((Position position) async {
          await _choforService.enviarUbicacion(
            entregaId,
            latitud: position.latitude,
            longitud: position.longitude,
            altitud: position.altitude,
            precision: position.accuracy,
            velocidad: position.speed * 3.6, // m/s a km/h
            rumbo: position.heading,
          );
        });

    notifyListeners();
  }

  Future<void> enviarUbicacionActual(int entregaId) async {
    try {
      Position position = await _geolocService.getCurrentPosition();
      await _choforService.enviarUbicacion(
        entregaId,
        latitud: position.latitude,
        longitud: position.longitude,
        altitud: position.altitude,
        precision: position.accuracy,
        velocidad: position.speed * 3.6,
        rumbo: position.heading,
      );
    } catch (e) {
      print('Error enviando ubicación: $e');
    }
  }

  void detenerCompartirUbicacion() {
    _compartiendoUbicacion = false;
    _ubicacionTimer?.cancel();
    _positionSubscription?.cancel();
    notifyListeners();
  }

  // ACTUALIZAR ESTADO
  Future<void> actualizarEstado(
    int entregaId,
    EstadoEntrega nuevoEstado, {
    String? observaciones,
  }) async {
    await _choforService.actualizarEstado(
      entregaId,
      nuevoEstado,
      observaciones: observaciones,
    );
    if (_entregaActual?.id == entregaId) {
      _entregaActual?.estado = nuevoEstado;
    }
    notifyListeners();
  }

  Future<void> marcarLlegada(int entregaId) async {
    await _choforService.marcarLlegada(entregaId);
    if (_entregaActual?.id == entregaId) {
      _entregaActual?.estado = EstadoEntrega.LLEGO;
    }
    notifyListeners();
  }

  // CONFIRMAR ENTREGA
  Future<void> confirmarEntrega(
    int entregaId,
    Uint8List firmaBytes, {
    List<File>? fotos,
    String? observaciones,
  }) async {
    await _choforService.confirmarEntrega(
      entregaId,
      firmaBytes: firmaBytes,
      fotos: fotos,
      observaciones: observaciones,
    );
    if (_entregaActual?.id == entregaId) {
      _entregaActual?.estado = EstadoEntrega.ENTREGADO;
    }
    detenerCompartirUbicacion();
    notifyListeners();
  }

  // REPORTAR NOVEDAD
  Future<void> reportarNovedad(
    int entregaId, {
    required String motivo,
    String? descripcion,
    List<File>? fotos,
  }) async {
    await _choforService.reportarNovedad(
      entregaId,
      motivo: motivo,
      descripcion: descripcion,
      fotos: fotos,
    );
    if (_entregaActual?.id == entregaId) {
      _entregaActual?.estado = EstadoEntrega.NOVEDAD;
    }
    notifyListeners();
  }

  // CREAR CLIENTE (NUEVO)
  Future<Client> crearCliente({
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    return await _choforService.crearCliente(
      nombres: nombres,
      apellidos: apellidos,
      email: email,
      telefono: telefono,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
    );
  }

  // GETTERS
  List<Entrega> get entregasAsignadas => _entregasAsignadas;
  Entrega? get entregaActual => _entregaActual;
  bool get isLoading => _isLoading;
  bool get compartiendoUbicacion => _compartiendoUbicacion;

  @override
  void dispose() {
    _ubicacionTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
```

---

## 7. SCREENS POR ROL

### 7.1 CLIENTE (Fase 1) ✅ EXISTENTES

```
├── home_cliente_screen
├── carrito_screen
├── pedidos_historial_screen
├── pedido_detalle_screen
├── pedido_tracking_screen (CRÍTICO: Mapa con tracking)
├── direccion_entrega_seleccion_screen
├── fecha_hora_entrega_screen
└── resumen_pedido_screen
```

**Estado:** ✅ Todos implementados

### 7.2 CHOFER (Fase 3) ❌ POR CREAR

```
├── home_chofer_screen ❌ CREAR
│   └── BottomNavigationBar con 3 tabs
│
├── entregas/
│   ├── entregas_asignadas_screen.dart ❌ CREAR
│   ├── entrega_detalle_screen.dart ❌ CREAR
│   ├── firma_digital_screen.dart ❌ CREAR
│   ├── reportar_novedad_screen.dart ❌ CREAR
│   └── entrega_completada_screen.dart ❌ CREAR
│
├── clientes/
│   ├── crear_cliente_screen.dart ❌ CREAR (NUEVO FEATURE)
│   └── listar_clientes_screen.dart (FUTURO)
│
├── historial/
│   └── historial_entregas_screen.dart ❌ CREAR
│
└── perfil/
    └── perfil_chofer_screen.dart ❌ CREAR
```

#### HomeChoferScreen (Principal)
```dart
// lib/screens/chofer/home_chofer_screen.dart

class HomeChoferScreen extends StatefulWidget {
  @override
  _HomeChoferScreenState createState() => _HomeChoferScreenState();
}

class _HomeChoferScreenState extends State<HomeChoferScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    EntregasAsignadasScreen(),    // Tab: Entregas Hoy
    HistorialEntregasScreen(),    // Tab: Historial
    PerfilChoferScreen(),         // Tab: Perfil
  ];

  @override
  void initState() {
    super.initState();
    // Conectar WebSocket
    // Cargar entregas del día
    Provider.of<ChoferProvider>(context, listen: false).loadEntregasDelDia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Jornada de Entregas'),
        actions: [
          // Badge con número de entregas
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Entregas'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
```

#### EntregasAsignadasScreen
```dart
// lib/screens/chofer/entregas/entregas_asignadas_screen.dart

// Mostrar lista de entregas del día
// Card para cada entrega con:
// - Cliente
// - Dirección
// - Estado actual
// - Botones de acción
// Click → EntregaDetalleScreen
```

#### EntregaDetalleScreen (CRÍTICO)
```dart
// lib/screens/chofer/entregas/entrega_detalle_screen.dart

// Mostrar detalle completo
// - Cliente, dirección, productos
// - Ubicación en mapa
// - Botones de acción según estado:
//   - Si ASIGNADA: "Iniciar Ruta"
//   - Si EN_CAMINO: "Marcar Llegada"
//   - Si LLEGO: "Confirmar Entrega"
// - Chat/contacto con cliente (futuro)
```

#### FirmaDigitalScreen
```dart
// lib/screens/chofer/entregas/firma_digital_screen.dart

// Captura de firma digital
// - SignaturePad (usar: signature)
// - Botones: Borrar, Confirmar
// - Opción: Capturar foto del producto
// - Preview antes de enviar
```

#### ReportarNovedadScreen
```dart
// lib/screens/chofer/entregas/reportar_novedad_screen.dart

// Formulario de novedad
// - Select de motivo (dropdown):
//   - CLIENTE_NO_ESTA
//   - DIRECCION_INCORRECTA
//   - PRODUCTO_DAÑADO
//   - OTRO
// - Descripción (textarea)
// - Captura de fotos (multiselect)
// - Botón: Reportar Novedad
```

#### CrearClienteScreen (NUEVO)
```dart
// lib/screens/chofer/clientes/crear_cliente_screen.dart

// Permitir al chofer crear nuevos clientes mientras entrega
// - Nombres, Apellidos
// - Email, Teléfono
// - Dirección (autocomplete o mapa)
// - Latitud, Longitud (auto desde GPS)
// - Validaciones básicas
// - Botón: Crear Cliente

// Este es un FEATURE NUEVO para que el chofer registre
// nuevos clientes en ruta sin depender de admin
```

---

## 8. SISTEMA DE TRACKING GPS

### 8.1 Requisitos Técnicos

```dart
// pubspec.yaml (VERIFICAR/INSTALAR)

dependencies:
  geolocator: ^14.0.2 ✅
  geocoding: ^4.0.0 ✅
  google_maps_flutter: ^2.12.3 ✅
  permission_handler: ^12.0.1 ✅
  image_picker: ^1.1.2 ✅
  signature: ^6.0.0 (INSTALAR - para firma digital)
```

### 8.2 Tracking en Cliente

```dart
// lib/screens/cliente/pedidos/pedido_tracking_screen.dart

// Cliente ve tracking en TIEMPO REAL
// - Mapa con pin del camión
// - Pin del destino
// - Línea de ruta
// - ETA actualizado
// - Info del chofer (nombre, foto, contacto)
// - Actualización cada 5-10 segundos vía WebSocket
```

### 8.3 Tracking en Chofer

```dart
// Durante la entrega

// 1. Chofer hace click "Iniciar Ruta"
//    ↓
// 2. Solicitar permisos de ubicación (background)
//    ↓
// 3. Iniciar Timer/Stream de ubicación
//    ↓
// 4. Cada 15 segundos:
//    - Obtener GPS actual
//    - Enviar: POST /api/chofer/entregas/{id}/ubicacion
//    - Backend recibe y dispara evento broadcast
//    ↓
// 5. Cliente ve actualización en tiempo real en su app
```

---

## 9. INTEGRACIÓN WEBSOCKET

### 9.1 WebSocket en Cliente

```dart
// lib/screens/cliente/pedidos/pedido_tracking_screen.dart

void initState() {
  super.initState();

  // Conectar WebSocket
  final wsService = context.read<WebSocketService>();
  wsService.conectar();

  // Escuchar eventos de proforma
  wsService.escucharPedido(
    widget.pedido.id,
    _onPedidoEvent
  );
}

void _onPedidoEvent(dynamic data) {
  // Eventos que pueden llegar:
  // - UbicacionActualizada: actualizar pin en mapa
  // - ChoferLlego: notificación
  // - PedidoEntregado: mostrar comprobantes
  // - NovedadReportada: alert rojo

  print('Evento: ${data['type']}');
  // Actualizar estado
}
```

### 9.2 WebSocket en Chofer

```dart
// lib/screens/chofer/home_chofer_screen.dart

void initState() {
  super.initState();

  // Conectar WebSocket
  final wsService = context.read<WebSocketService>();
  wsService.conectar();

  // Escuchar asignaciones de entregas
  wsService.escucharCanalChofer(
    chofer.id,
    _onNovaEntrega
  );
}

void _onNovaEntrega(dynamic data) {
  // Evento: EntregaAsignada
  // - Nueva entrega asignada al chofer
  // - Recargar lista de entregas
  // - Mostrar notificación
}
```

---

## 10. FLUJOS PRINCIPALES

### 10.1 Flujo: Cliente Crea Pedido y Ve Tracking

```
1. Cliente agrega productos al carrito
   ↓
2. Click "Continuar Compra"
   ↓
3. Selecciona dirección entrega
   ↓
4. Selecciona fecha/hora
   ↓
5. Ve resumen, confirma
   ↓
6. POST /api/app/pedidos
   ↓
7. Backend: Crear Proforma, Reservar stock
   ↓
8. Retorna: Proforma creada
   ↓
9. Navegar a PedidoCreadoScreen (éxito)
   ↓
10. Click "Ver Tracking"
    ↓
11. Abre PedidoTrackingScreen
    ↓
12. WebSocket se conecta: escuchar eventos
    ↓
13. Espera a que Encargado apruebe
    ↓
14. Evento: ProformaAprobada (WebSocket)
    ↓
15. UI actualiza: estado APROBADA
    ↓
16. Espera a que Encargado asigne chofer
    ↓
17. Evento: EntregaAsignada
    ↓
18. UI muestra: nombre chofer, placa, ETA
    ↓
19. Chofer inicia ruta
    ↓
20. Evento: ChoferEnCamino (WebSocket)
    ↓
21. Mapa se actualiza cada 15 segundos
    ↓
22. Chofer llega
    ↓
23. Evento: ChoferLlego
    ↓
24. Notificación: "Tu pedido ha llegado"
    ↓
25. Chofer confirma entrega (firma + foto)
    ↓
26. Evento: PedidoEntregado
    ↓
27. UI muestra comprobantes
```

### 10.2 Flujo: Chofer Realiza Entrega

```
1. Chofer abre app, ve lista de entregas
   ↓
2. Click en entrega → EntregaDetalleScreen
   ↓
3. Lee info: cliente, dirección, productos
   ↓
4. Click "Iniciar Ruta"
   ↓
5. Solicitar permisos GPS
   ↓
6. Iniciar Timer: enviar ubicación cada 15s
   ↓
7. Cliente recibe: Evento ChoferEnCamino (WebSocket)
   ↓
8. Cliente ve mapa: pin del camión se mueve
   ↓
9. Chofer llega a dirección
   ↓
10. Click "Marcar Llegada"
    ↓
11. POST /api/chofer/entregas/{id}/marcar-llegada
    ↓
12. Backend: cambiar estado a LLEGO
    ↓
13. Cliente recibe: Evento ChoferLlego
    ↓
14. Notificación al cliente
    ↓
15. Chofer: Click "Confirmar Entrega"
    ↓
16. Abre FirmaDigitalScreen
    ↓
17. Cliente firma en pantalla
    ↓
18. Chofer captura foto(s) de comprobante
    ↓
19. Click "Confirmar"
    ↓
20. POST /api/chofer/entregas/{id}/confirmar-entrega
    ↓
21. Backend: guardar firma + fotos, cambiar estado ENTREGADO
    ↓
22. Cliente recibe: Evento PedidoEntregado
    ↓
23. UI muestra: "Entregado" con comprobantes
```

### 10.3 Flujo: Chofer Reporta Novedad

```
1. Chofer intenta entregar
2. Cliente no está o dirección incorrecta
3. Click "Reportar Novedad"
4. Abre ReportarNovedadScreen
5. Selecciona motivo (dropdown)
6. Ingresa descripción
7. Captura fotos
8. Click "Reportar"
9. POST /api/chofer/entregas/{id}/reportar-novedad
10. Backend: cambiar estado NOVEDAD
11. Admin recibe: Evento NovedadReportada (alerta roja)
12. Cliente recibe: notificación de novedad
```

---

## 11. CHECKLIST DE IMPLEMENTACIÓN

### FASE 1 (CLIENTE) ✅ COMPLETADA

- [x] Carrito de compras
- [x] Crear proformas
- [x] Historial de pedidos
- [x] Detalle de pedido
- [x] Tracking básico
- [x] Todos los modelos
- [x] Todos los servicios
- [x] WebSocket service

### FASE 2 (NOTIFICACIONES) ❌ A HACER (Backend first)

- [ ] Instalar `firebase_messaging`
- [ ] Crear `NotificationProvider`
- [ ] Integrar FCM con backend
- [ ] Mostrar notificaciones push
- [ ] Notificaciones locales

### FASE 3 (CHOFER) ❌ CRÍTICA - POR INICIAR

**Modelos:**
- [ ] Crear Model `Entrega`
- [ ] Expandir Model `Chofer`
- [ ] Expandir Model `Camion`

**Servicios:**
- [ ] Crear `ChoferService` (18 métodos)
- [ ] Crear `GeolocationService`
- [ ] Crear `FileService` (para firma + fotos)

**Providers:**
- [ ] Crear `ChoferProvider` (estado + métodos)
- [ ] Crear `LocationProvider`
- [ ] Expandir `TrackingProvider`

**Screens (9 screens nuevas):**
- [ ] `HomeChoferScreen` (principal)
- [ ] `EntregasAsignadasScreen`
- [ ] `EntregaDetalleScreen`
- [ ] `FirmaDigitalScreen`
- [ ] `ReportarNovedadScreen`
- [ ] `EntregaCompletadaScreen`
- [ ] `HistorialEntregasScreen`
- [ ] `PerfilChoferScreen`
- [ ] `CrearClienteScreen` (NUEVO)

**Widgets:**
- [ ] `EntregaCard`
- [ ] `ChoferInfoCard`
- [ ] `FirmaPreviewWidget`
- [ ] `LocationPermissionDialog`

**Testing:**
- [ ] Unit tests para modelos
- [ ] Unit tests para providers
- [ ] Integration tests para flujos
- [ ] Testing en dispositivo real (GPS, etc.)

### FASE 4 (PULIDO)

- [ ] UI/UX consistente
- [ ] Performance (lazy loading, memoización)
- [ ] Manejo de errores
- [ ] Offline support (opcional)
- [ ] Testing QA completo
- [ ] Release

---

## 12. DEPENDENCIAS A AÑADIR/VERIFICAR

```yaml
dependencies:
  # EXISTENTES (VERIFICAR)
  geolocator: ^14.0.2 ✅
  google_maps_flutter: ^2.12.3 ✅
  image_picker: ^1.1.2 ✅
  permission_handler: ^12.0.1 ✅
  laravel_echo: ^1.0.0-beta.1 ✅

  # INSTALAR PARA CHOFER
  signature: ^6.0.0 ❌ INSTALAR (firma digital)
  geocoding: ^4.0.0 ✅ (ya existe)

  # INSTALAR PARA NOTIFICACIONES
  firebase_messaging: ^14.0.0 ❌ INSTALAR
```

---

## 13. PRÓXIMOS PASOS (ORDEN RECOMENDADO)

1. **Backend completa todos los endpoints** (BLOQUEANTE)
2. **WebSocket funciona correctamente** (BLOQUEANTE)
3. **Instalación de dependencias faltantes** en Flutter
4. **Crear modelos:** Entrega, expansiones
5. **Crear ChoferService** (métodos API)
6. **Crear ChoferProvider** (state management)
7. **Crear HomeChoferScreen**
8. **Crear screens de entregas** (uno a uno)
9. **Testing y debugging**
10. **Release de v2.0 con ambos roles**

---

## 14. NOTAS IMPORTANTES

- **Una sola app Flutter:** mismo código para Cliente y Chofer (detectar rol en login)
- **WebSocket crítico:** Sin él, no hay actualizaciones en tiempo real
- **GPS en background:** Chofer debe poder compartir ubicación incluso si app está en background
- **Firma digital:** Usar package `signature` o similar
- **Foto de comprobante:** Usar `image_picker` (ya instalado)
- **Crear clientes en ruta:** Feature nuevo que facilita trabajo del chofer

---

**Versión:** 2.0
**Última actualización:** 31 de Octubre de 2025
**Gestor:** Gestor de Flutter
**Siguiente revisión:** Cuando Backend complete todos los endpoints y WebSocket esté funcionando
