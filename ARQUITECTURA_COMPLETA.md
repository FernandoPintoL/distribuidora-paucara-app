# 🏗️ ARQUITECTURA COMPLETA - SISTEMA DISTRIBUIDORA

**Versión:** 1.0
**Fecha:** 2025-10-18
**Proyecto:** Sistema Multi-Rol de Distribuidora (Cliente, Chofer, Admin)

---

## 📋 ÍNDICE

1. [Visión General](#visión-general)
2. [Roles y Funcionalidades](#roles-y-funcionalidades)
3. [Arquitectura de Datos](#arquitectura-de-datos)
4. [Arquitectura de Servicios](#arquitectura-de-servicios)
5. [Arquitectura de Presentación](#arquitectura-de-presentación)
6. [Sistema de Notificaciones en Tiempo Real](#sistema-de-notificaciones-en-tiempo-real)
7. [Sistema de Tracking Geoespacial](#sistema-de-tracking-geoespacial)
8. [Flujos de Navegación](#flujos-de-navegación)
9. [Extensiones de API Necesarias](#extensiones-de-api-necesarias)
10. [Plan de Implementación](#plan-de-implementación)

---

## 1. VISIÓN GENERAL

### 1.1 Objetivos del Sistema

El sistema debe permitir:

**FASE 1 - ROL CLIENTE:**
- Ver catálogo de productos
- Crear proforma/pedido (carrito de compras)
- Seleccionar fecha/hora preferida de entrega
- Ver historial de pedidos
- Trackear estado del pedido en tiempo real:
  - PENDIENTE → APROBADA → PREPARANDO → EN CAMIÓN → EN RUTA → ENTREGADO

**FASE 2 - ROL CHOFER:**
- Ver pedidos asignados del día
- Navegar con GPS a ubicación del cliente
- Actualizar estado de entrega en tiempo real
- Confirmar entregas con firma digital y/o foto
- Ver historial de entregas realizadas

**FASE 3 - ROL ADMIN/ENCARGADO:**
- Aprobar/rechazar proformas
- Asignar pedidos a choferes
- Asignar pedidos a camiones/vehículos
- Ver tracking en tiempo real de todos los pedidos
- Gestión de productos y clientes (ya implementado)
- Dashboard con métricas

### 1.2 Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (Multi-Rol)                  │
├─────────────────────────────────────────────────────────────┤
│  CAPA PRESENTACIÓN (Screens & Widgets)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Cliente    │  │    Chofer    │  │    Admin     │      │
│  │   Screens    │  │   Screens    │  │   Screens    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  CAPA LÓGICA (Providers - State Management)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Auth      │  │   Pedidos    │  │   Tracking   │      │
│  │   Provider   │  │   Provider   │  │   Provider   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Carrito    │  │    Chofer    │  │Notificaciones│      │
│  │   Provider   │  │   Provider   │  │   Provider   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  CAPA SERVICIOS (API Services)                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Pedidos    │  │   Tracking   │  │    Chofer    │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  CAPA COMUNICACIÓN                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  API Service │  │ WebSocket/   │  │   Firebase   │      │
│  │     (Dio)    │  │ Laravel Echo │  │  Messaging   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND LARAVEL API                       │
├─────────────────────────────────────────────────────────────┤
│  API REST + WebSockets (Broadcasting)                       │
│  - Endpoints CRUD                                            │
│  - Sistema de eventos en tiempo real                        │
│  - Geolocalización y tracking                               │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    BASE DE DATOS                             │
│  - Usuarios, Roles, Permisos                                │
│  - Productos, Categorías, Marcas                            │
│  - Clientes, Direcciones                                     │
│  - Proformas, Pedidos, Items                                │
│  - Entregas, Tracking, Ubicaciones                          │
│  - Camiones, Choferes, Asignaciones                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. ROLES Y FUNCIONALIDADES

### 2.1 ROL: CLIENTE

| Funcionalidad | Descripción | Prioridad |
|--------------|-------------|-----------|
| **Catálogo de Productos** | Ver productos con filtros (categoría, marca, búsqueda) | ✅ Implementado |
| **Carrito de Compras** | Agregar/quitar productos, ver total | 🔴 Crítico |
| **Crear Proforma** | Convertir carrito en proforma + seleccionar dirección y fecha/hora | 🔴 Crítico |
| **Historial de Pedidos** | Ver todas las proformas creadas | 🔴 Crítico |
| **Detalle de Pedido** | Ver estado actual, items, totales | 🔴 Crítico |
| **Tracking en Tiempo Real** | Ver progreso del pedido (PENDIENTE → ENTREGADO) | 🟡 Alto |
| **Ver Chofer Asignado** | Nombre, foto, placa del camión | 🟡 Alto |
| **Ver Ubicación en Mapa** | Tracking GPS del camión en ruta | 🟡 Alto |
| **Notificaciones Push** | Alertas de cambios de estado | 🟡 Alto |
| **Gestión de Direcciones** | CRUD de direcciones de entrega | ✅ Implementado |
| **Extender Reserva de Stock** | Solicitar más tiempo si proforma cerca de vencer | 🟢 Medio |

### 2.2 ROL: CHOFER

| Funcionalidad | Descripción | Prioridad |
|--------------|-------------|-----------|
| **Ver Pedidos del Día** | Lista de entregas asignadas | 🔴 Crítico |
| **Detalle de Entrega** | Cliente, dirección, productos, total | 🔴 Crítico |
| **Navegación GPS** | Abrir Google Maps/Waze a ubicación cliente | 🔴 Crítico |
| **Actualizar Estado** | Marcar como: EN RUTA, LLEGÓ, ENTREGADO, NOVEDAD | 🔴 Crítico |
| **Confirmar Entrega** | Captura de firma digital del cliente | 🟡 Alto |
| **Foto de Comprobante** | Foto del producto entregado | 🟡 Alto |
| **Reportar Novedades** | Cliente no está, dirección incorrecta, producto dañado | 🟡 Alto |
| **Historial de Entregas** | Ver todas las entregas realizadas | 🟢 Medio |
| **Compartir Ubicación** | GPS en tiempo real mientras está en ruta | 🟡 Alto |

### 2.3 ROL: ADMIN/ENCARGADO

| Funcionalidad | Descripción | Prioridad |
|--------------|-------------|-----------|
| **Gestión de Productos** | CRUD productos (parcialmente implementado) | ✅ Parcial |
| **Gestión de Clientes** | CRUD clientes | ✅ Implementado |
| **Aprobar/Rechazar Proformas** | Revisar y decidir sobre pedidos | 🔴 Crítico |
| **Asignar Chofer** | Asignar entrega a un chofer específico | 🔴 Crítico |
| **Asignar Camión** | Asignar vehículo para la entrega | 🔴 Crítico |
| **Dashboard de Pedidos** | Ver todos los pedidos con filtros | 🔴 Crítico |
| **Tracking Múltiple** | Ver mapa con todos los camiones activos | 🟡 Alto |
| **Reportes** | Ventas, entregas, productos más vendidos | 🟢 Medio |
| **Gestión de Choferes** | CRUD de choferes | 🟢 Medio |
| **Gestión de Camiones** | CRUD de vehículos | 🟢 Medio |

---

## 3. ARQUITECTURA DE DATOS

### 3.1 Modelos Existentes (Ya Implementados)

```dart
✅ User - Usuario con roles y permisos
✅ Client - Cliente con direcciones y ventanas de entrega
✅ Product - Producto con categorías, marcas, precios
✅ ClientAddress - Dirección de entrega con GPS
✅ Localidad - Localidades/Ciudades
✅ CategoriaCliente - Categorías de cliente
```

### 3.2 Nuevos Modelos Requeridos

#### 3.2.1 Módulo de Pedidos

```dart
// lib/models/pedido.dart
class Pedido {
  final int id;
  final String numero;                    // PRO-20251018-0001
  final int clienteId;
  final Client? cliente;
  final int? direccionId;
  final ClientAddress? direccionEntrega;

  // Estados del pedido
  final EstadoPedido estado;
  final DateTime? fechaProgramada;        // Fecha/hora solicitada por cliente
  final DateTime? horaInicioPreferida;
  final DateTime? horaFinPreferida;

  // Montos
  final double subtotal;
  final double impuesto;
  final double total;
  final String? observaciones;

  // Items del pedido
  final List<PedidoItem> items;

  // Tracking
  final List<PedidoEstadoHistorial> historialEstados;
  final List<ReservaStock> reservas;

  // Asignaciones (para admin/chofer)
  final int? choferId;
  final Chofer? chofer;
  final int? camionId;
  final Camion? camion;

  // Metadata
  final String canalOrigen;              // APP_EXTERNA, CALL_CENTER, etc.
  final DateTime fechaCreacion;
  final DateTime? fechaAprobacion;
  final DateTime? fechaEntrega;
  final int? usuarioAprobadorId;
  final String? comentariosAprobacion;

  // Comprobantes de entrega
  final String? firmaDigitalUrl;
  final String? fotoEntregaUrl;
  final DateTime? fechaFirmaEntrega;
}

enum EstadoPedido {
  PENDIENTE,        // Cliente creó la proforma
  APROBADA,         // Admin aprobó
  RECHAZADA,        // Admin rechazó
  PREPARANDO,       // Se está armando el pedido
  EN_CAMION,        // Cargado en el camión
  EN_RUTA,          // Chofer salió a entregar
  LLEGO,            // Chofer llegó a ubicación
  ENTREGADO,        // Cliente recibió y firmó
  NOVEDAD,          // Hubo un problema
  VENCIDA,          // Venció el tiempo de reserva
}

class EstadoInfo {
  final EstadoPedido codigo;
  final String nombre;
  final String descripcion;
  final String color;              // Color hex para UI
  final String icono;              // Nombre del icono
  final bool puedeCancel;
}

// lib/models/pedido_item.dart
class PedidoItem {
  final int id;
  final int pedidoId;
  final int productoId;
  final Product? producto;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? observaciones;
}

// lib/models/pedido_estado_historial.dart
class PedidoEstadoHistorial {
  final int id;
  final int pedidoId;
  final EstadoPedido estadoAnterior;
  final EstadoPedido estadoNuevo;
  final int? usuarioId;
  final String? nombreUsuario;
  final String? comentario;
  final DateTime fecha;
  final Map<String, dynamic>? metadata;   // Datos extras (GPS, etc.)
}

// lib/models/reserva_stock.dart
class ReservaStock {
  final int id;
  final int pedidoId;
  final int productoId;
  final Product? producto;
  final double cantidad;
  final EstadoReserva estado;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  final DateTime? fechaLiberacion;
}

enum EstadoReserva {
  ACTIVA,
  CONFIRMADA,
  LIBERADA,
  VENCIDA,
}
```

#### 3.2.2 Módulo de Choferes y Vehículos

```dart
// lib/models/chofer.dart
class Chofer {
  final int id;
  final int userId;               // Relación con User
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
}

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
}

// lib/models/entrega.dart
class Entrega {
  final int id;
  final int pedidoId;
  final Pedido? pedido;
  final int choferId;
  final Chofer? chofer;
  final int camionId;
  final Camion? camion;
  final DateTime fechaAsignacion;
  final DateTime? fechaInicio;         // Cuando chofer sale
  final DateTime? fechaLlegada;        // Cuando chofer llega
  final DateTime? fechaEntrega;        // Cuando cliente firma
  final EstadoEntrega estado;
  final String? observaciones;
  final String? motivoNovedad;

  // Comprobantes
  final String? firmaDigitalUrl;
  final List<String>? fotosEntregaUrls;

  // Tracking GPS
  final List<UbicacionTracking> ubicaciones;
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

#### 3.2.3 Módulo de Tracking Geoespacial

```dart
// lib/models/ubicacion_tracking.dart
class UbicacionTracking {
  final int id;
  final int entregaId;
  final int? choferId;
  final double latitud;
  final double longitud;
  final double? altitud;
  final double? precision;            // Accuracy en metros
  final double? velocidad;            // km/h
  final double? rumbo;                // Bearing en grados
  final DateTime timestamp;
  final String? evento;               // "inicio_ruta", "llegada", "entrega"
}

// lib/models/ruta.dart
class Ruta {
  final int id;
  final int choferId;
  final DateTime fecha;
  final List<Entrega> entregas;       // Entregas en orden
  final double? distanciaTotal;       // km
  final DateTime? horaInicio;
  final DateTime? horaFin;
  final String? estado;               // EN_CURSO, FINALIZADA
}
```

#### 3.2.4 Módulo de Carrito de Compras (Local)

```dart
// lib/models/carrito.dart
class Carrito {
  final List<CarritoItem> items;
  final double subtotal;
  final double impuesto;
  final double total;

  int get cantidadItems => items.length;
  int get cantidadProductos => items.fold(0, (sum, item) => sum + item.cantidad.toInt());
}

// lib/models/carrito_item.dart
class CarritoItem {
  final Product producto;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? observaciones;

  // Constructor con cálculo automático
  CarritoItem({
    required this.producto,
    required this.cantidad,
    double? precioUnitario,
    this.observaciones,
  }) : precioUnitario = precioUnitario ?? producto.precioVenta,
       subtotal = (precioUnitario ?? producto.precioVenta) * cantidad;
}
```

---

## 4. ARQUITECTURA DE SERVICIOS

### 4.1 Servicios Existentes (Ya Implementados)

```dart
✅ ApiService - HTTP client con Dio, interceptores, tokens
✅ AuthService - Login, registro, logout, refresh token
✅ ProductService - CRUD productos
✅ ClientService - CRUD clientes y direcciones
```

### 4.2 Nuevos Servicios Requeridos

#### 4.2.1 PedidoService

```dart
// lib/services/pedido_service.dart
class PedidoService {
  final ApiService _apiService;

  // Crear proforma
  Future<Pedido> crearPedido({
    required int direccionId,
    required List<Map<String, dynamic>> items,
    DateTime? fechaProgramada,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    String? observaciones,
  });

  // Historial de pedidos del cliente
  Future<PaginatedResponse<Pedido>> getPedidosCliente({
    int page = 1,
    int perPage = 15,
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  // Detalle de pedido
  Future<Pedido> getPedido(int id);

  // Consultar solo el estado (lightweight)
  Future<EstadoPedidoResponse> getEstadoPedido(int id);

  // Extender reserva de stock
  Future<void> extenderReservas(int pedidoId);

  // Verificar stock antes de crear pedido
  Future<VerificacionStockResponse> verificarStock(
    List<Map<String, dynamic>> items
  );
}
```

#### 4.2.2 ChoferService

```dart
// lib/services/chofer_service.dart
class ChoferService {
  final ApiService _apiService;

  // Ver pedidos/entregas asignadas al chofer
  Future<List<Entrega>> getEntregasAsignadas({
    DateTime? fecha,
    EstadoEntrega? estado,
  });

  // Detalle de entrega
  Future<Entrega> getEntrega(int id);

  // Iniciar ruta (cuando chofer sale)
  Future<void> iniciarRuta(int entregaId);

  // Actualizar estado de entrega
  Future<void> actualizarEstadoEntrega(
    int entregaId,
    EstadoEntrega nuevoEstado, {
    String? observaciones,
    String? motivoNovedad,
  });

  // Marcar como llegó
  Future<void> marcarLlegada(int entregaId);

  // Confirmar entrega con firma
  Future<void> confirmarEntrega(
    int entregaId, {
    required String firmaBase64,
    List<String>? fotosBase64,
    String? observaciones,
  });

  // Reportar novedad
  Future<void> reportarNovedad(
    int entregaId, {
    required String motivo,
    String? descripcion,
    List<String>? fotosBase64,
  });

  // Enviar ubicación GPS en tiempo real
  Future<void> enviarUbicacion(
    int entregaId, {
    required double latitud,
    required double longitud,
    double? altitud,
    double? precision,
    double? velocidad,
    double? rumbo,
    String? evento,
  });

  // Historial de entregas
  Future<PaginatedResponse<Entrega>> getHistorialEntregas({
    int page = 1,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
}
```

#### 4.2.3 AdminService

```dart
// lib/services/admin_service.dart
class AdminService {
  final ApiService _apiService;

  // Dashboard - todos los pedidos
  Future<PaginatedResponse<Pedido>> getPedidos({
    int page = 1,
    int perPage = 20,
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? clienteId,
    int? choferId,
  });

  // Aprobar proforma
  Future<void> aprobarProforma(
    int pedidoId, {
    String? comentarios,
  });

  // Rechazar proforma
  Future<void> rechazarProforma(
    int pedidoId, {
    required String motivo,
  });

  // Asignar chofer y camión
  Future<void> asignarEntrega(
    int pedidoId, {
    required int choferId,
    required int camionId,
    DateTime? fechaProgramada,
  });

  // CRUD Choferes
  Future<List<Chofer>> getChoferes({bool? activo});
  Future<Chofer> getChofer(int id);
  Future<Chofer> crearChofer(Map<String, dynamic> data);
  Future<Chofer> actualizarChofer(int id, Map<String, dynamic> data);
  Future<void> eliminarChofer(int id);

  // CRUD Camiones
  Future<List<Camion>> getCamiones({bool? activo});
  Future<Camion> getCamion(int id);
  Future<Camion> crearCamion(Map<String, dynamic> data);
  Future<Camion> actualizarCamion(int id, Map<String, dynamic> data);
  Future<void> eliminarCamion(int id);

  // Tracking múltiple
  Future<List<EntregaTracking>> getEntregasActivas();
}
```

#### 4.2.4 TrackingService

```dart
// lib/services/tracking_service.dart
class TrackingService {
  final ApiService _apiService;

  // Obtener ubicaciones de una entrega
  Future<List<UbicacionTracking>> getUbicacionesEntrega(int entregaId);

  // Obtener última ubicación conocida
  Future<UbicacionTracking?> getUltimaUbicacion(int entregaId);

  // Calcular distancia estimada de llegada
  Future<DistanciaEstimada> calcularDistanciaLlegada(
    int entregaId,
    double latCliente,
    double lngCliente,
  });
}

class DistanciaEstimada {
  final double distanciaMetros;
  final int tiempoEstimadoMinutos;
  final String distanciaFormateada;  // "2.5 km"
  final String tiempoFormateado;     // "15 min"
}
```

### 4.3 Servicio de Notificaciones

```dart
// lib/services/notification_service.dart
class NotificationService {
  // Inicializar FCM (Firebase Cloud Messaging)
  Future<void> initialize();

  // Solicitar permisos
  Future<bool> requestPermissions();

  // Obtener FCM token y enviarlo al backend
  Future<String?> getFCMToken();
  Future<void> enviarTokenAlBackend(String token);

  // Manejar notificaciones recibidas
  void onMessageReceived(RemoteMessage message);
  void onMessageOpenedApp(RemoteMessage message);

  // Mostrar notificación local
  void mostrarNotificacionLocal(String titulo, String mensaje);

  // Suscribirse a topics (opcional)
  Future<void> suscribirseATopic(String topic);
}
```

### 4.4 Servicio de WebSockets (Tiempo Real)

```dart
// lib/services/websocket_service.dart
class WebSocketService {
  late Echo echo;

  // Conectar a Laravel Echo
  Future<void> connect(String token);

  // Desconectar
  void disconnect();

  // Escuchar eventos de un pedido específico
  void escucharPedido(int pedidoId, Function(dynamic) callback);

  // Escuchar eventos de una entrega
  void escucharEntrega(int entregaId, Function(dynamic) callback);

  // Escuchar canal del chofer
  void escucharCanalChofer(int choferId, Function(dynamic) callback);

  // Dejar de escuchar
  void dejarDeEscuchar(String canal);
}
```

---

## 5. ARQUITECTURA DE PRESENTACIÓN

### 5.1 Providers (State Management)

#### 5.1.1 Providers Existentes (Ya Implementados)

```dart
✅ AuthProvider - Login, roles, permisos
✅ ProductProvider - CRUD productos
✅ ClientProvider - CRUD clientes
```

#### 5.1.2 Nuevos Providers Requeridos

```dart
// lib/providers/carrito_provider.dart
class CarritoProvider extends ChangeNotifier {
  Carrito _carrito = Carrito(items: []);

  // Agregar producto al carrito
  void agregarProducto(Product producto, double cantidad);

  // Actualizar cantidad
  void actualizarCantidad(int productoId, double nuevaCantidad);

  // Eliminar producto
  void eliminarProducto(int productoId);

  // Limpiar carrito
  void limpiarCarrito();

  // Verificar stock disponible antes de crear pedido
  Future<bool> verificarStock();

  // Convertir carrito a pedido
  Future<Pedido?> crearPedido({
    required int direccionId,
    DateTime? fechaProgramada,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    String? observaciones,
  });

  // Getters
  Carrito get carrito => _carrito;
  int get cantidadItems => _carrito.cantidadItems;
  double get total => _carrito.total;
}

// lib/providers/pedido_provider.dart
class PedidoProvider extends ChangeNotifier {
  List<Pedido> _pedidos = [];
  Pedido? _pedidoActual;
  bool _isLoading = false;
  String? _errorMessage;
  PaginationInfo? _paginationInfo;

  // Cargar historial de pedidos
  Future<void> loadPedidos({
    int page = 1,
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  // Cargar más pedidos (infinite scroll)
  Future<void> loadMore();

  // Obtener detalle de un pedido
  Future<void> loadPedido(int id);

  // Refrescar estado de un pedido
  Future<void> refreshEstadoPedido(int id);

  // Extender reserva
  Future<void> extenderReserva(int pedidoId);

  // Filtrar pedidos localmente
  List<Pedido> getPedidosPorEstado(EstadoPedido estado);

  // Getters
  List<Pedido> get pedidos => _pedidos;
  Pedido? get pedidoActual => _pedidoActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}

// lib/providers/chofer_provider.dart
class ChoferProvider extends ChangeNotifier {
  List<Entrega> _entregasAsignadas = [];
  Entrega? _entregaActual;
  bool _isLoading = false;
  Timer? _ubicacionTimer;

  // Cargar entregas del día
  Future<void> loadEntregasDelDia();

  // Cargar detalle de entrega
  Future<void> loadEntrega(int id);

  // Iniciar ruta
  Future<void> iniciarRuta(int entregaId);

  // Actualizar estado
  Future<void> actualizarEstado(
    int entregaId,
    EstadoEntrega nuevoEstado, {
    String? observaciones,
  });

  // Marcar llegada
  Future<void> marcarLlegada(int entregaId);

  // Confirmar entrega con firma
  Future<void> confirmarEntrega(
    int entregaId,
    Uint8List firmaBytes, {
    List<File>? fotos,
    String? observaciones,
  });

  // Reportar novedad
  Future<void> reportarNovedad(
    int entregaId, {
    required String motivo,
    String? descripcion,
    List<File>? fotos,
  });

  // Iniciar compartir ubicación GPS en tiempo real
  void iniciarCompartirUbicacion(int entregaId);

  // Detener compartir ubicación
  void detenerCompartirUbicacion();

  // Enviar ubicación actual
  Future<void> enviarUbicacionActual(int entregaId);

  // Getters
  List<Entrega> get entregasAsignadas => _entregasAsignadas;
  Entrega? get entregaActual => _entregaActual;
  bool get isLoading => _isLoading;
  bool get compartiendoUbicacion => _ubicacionTimer != null;
}

// lib/providers/admin_provider.dart
class AdminProvider extends ChangeNotifier {
  List<Pedido> _todosPedidos = [];
  List<Chofer> _choferes = [];
  List<Camion> _camiones = [];
  List<EntregaTracking> _entregasActivas = [];

  // Dashboard de pedidos
  Future<void> loadPedidos({
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  // Aprobar proforma
  Future<void> aprobarProforma(int pedidoId, {String? comentarios});

  // Rechazar proforma
  Future<void> rechazarProforma(int pedidoId, {required String motivo});

  // Asignar entrega
  Future<void> asignarEntrega(
    int pedidoId, {
    required int choferId,
    required int camionId,
    DateTime? fechaProgramada,
  });

  // Gestión de choferes
  Future<void> loadChoferes();
  Future<void> crearChofer(Map<String, dynamic> data);
  Future<void> actualizarChofer(int id, Map<String, dynamic> data);
  Future<void> eliminarChofer(int id);

  // Gestión de camiones
  Future<void> loadCamiones();
  Future<void> crearCamion(Map<String, dynamic> data);
  Future<void> actualizarCamion(int id, Map<String, dynamic> data);
  Future<void> eliminarCamion(int id);

  // Tracking en tiempo real
  Future<void> loadEntregasActivas();

  // Getters
  List<Pedido> get pedidos => _todosPedidos;
  List<Chofer> get choferes => _choferes;
  List<Camion> get camiones => _camiones;
  List<EntregaTracking> get entregasActivas => _entregasActivas;
}

// lib/providers/tracking_provider.dart
class TrackingProvider extends ChangeNotifier {
  UbicacionTracking? _ubicacionActual;
  List<UbicacionTracking> _historialUbicaciones = [];
  DistanciaEstimada? _distanciaEstimada;

  // Suscribirse a updates de tracking en tiempo real (WebSocket)
  void suscribirseATracking(int entregaId);

  // Desuscribirse
  void desuscribirse();

  // Cargar historial de ubicaciones
  Future<void> loadHistorialUbicaciones(int entregaId);

  // Actualizar ubicación actual (desde WebSocket)
  void actualizarUbicacion(UbicacionTracking ubicacion);

  // Calcular distancia estimada
  Future<void> calcularDistancia(int entregaId, double latCliente, double lngCliente);

  // Getters
  UbicacionTracking? get ubicacionActual => _ubicacionActual;
  List<UbicacionTracking> get historialUbicaciones => _historialUbicaciones;
  DistanciaEstimada? get distanciaEstimada => _distanciaEstimada;
}

// lib/providers/notification_provider.dart
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notificaciones = [];
  int _noLeidas = 0;

  // Inicializar servicio
  Future<void> initialize();

  // Agregar notificación
  void agregarNotificacion(AppNotification notificacion);

  // Marcar como leída
  void marcarComoLeida(int id);

  // Marcar todas como leídas
  void marcarTodasComoLeidas();

  // Limpiar todas
  void limpiarTodas();

  // Getters
  List<AppNotification> get notificaciones => _notificaciones;
  int get noLeidas => _noLeidas;
}
```

---

## 6. SISTEMA DE NOTIFICACIONES EN TIEMPO REAL

### 6.1 Arquitectura de Notificaciones

```
┌─────────────────────────────────────────────────────────────┐
│                   EVENTOS EN EL BACKEND                      │
├─────────────────────────────────────────────────────────────┤
│  - ProformaAprobada                                          │
│  - ProformaRechazada                                         │
│  - PedidoAsignado                                            │
│  - EstadoPedidoCambiado                                      │
│  - ChoferEnCamino                                            │
│  - ChoferLlego                                               │
│  - PedidoEntregado                                           │
│  - NovedadReportada                                          │
│  - UbicacionActualizada (GPS tracking)                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              CANALES DE BROADCASTING (Laravel)               │
├─────────────────────────────────────────────────────────────┤
│  - pedido.{pedido_id}        → Cliente escucha su pedido     │
│  - entrega.{entrega_id}      → Chofer escucha su entrega    │
│  - chofer.{chofer_id}        → Chofer recibe asignaciones   │
│  - admin.pedidos             → Admin ve todos los cambios   │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌──────────────────┴──────────────────┐
        │                                     │
┌───────▼────────┐                   ┌────────▼────────┐
│  WEBSOCKETS    │                   │  PUSH (FCM)     │
│ Laravel Echo   │                   │ Firebase        │
│ Pusher/Socket  │                   │ Cloud Messaging │
└───────┬────────┘                   └────────┬────────┘
        │                                     │
        └──────────────────┬──────────────────┘
                           ↓
              ┌────────────────────────┐
              │    FLUTTER APP         │
              ├────────────────────────┤
              │  - WebSocketService    │
              │  - NotificationService │
              │  - Providers escuchan  │
              │  - UI se actualiza     │
              └────────────────────────┘
```

### 6.2 Eventos y Canales

| Evento | Canal | Quién Escucha | Acción en Flutter |
|--------|-------|---------------|-------------------|
| `ProformaAprobada` | `pedido.{id}` | Cliente | Mostrar notificación, actualizar estado |
| `ProformaRechazada` | `pedido.{id}` | Cliente | Mostrar notificación con motivo |
| `PedidoAsignado` | `pedido.{id}` + `chofer.{id}` | Cliente + Chofer | Mostrar chofer y camión asignado |
| `EstadoPedidoCambiado` | `pedido.{id}` | Cliente | Actualizar timeline de estados |
| `ChoferEnCamino` | `pedido.{id}` + `entrega.{id}` | Cliente | Mostrar "En camino", activar tracking |
| `UbicacionActualizada` | `entrega.{id}` | Cliente (tracking) | Actualizar pin en mapa en tiempo real |
| `ChoferLlego` | `pedido.{id}` | Cliente | Notificación "Tu pedido ha llegado" |
| `PedidoEntregado` | `pedido.{id}` | Cliente + Admin | Mostrar confirmación de entrega |
| `NovedadReportada` | `pedido.{id}` + `admin.pedidos` | Cliente + Admin | Alert de problema en entrega |
| `NuevaProformaCreada` | `admin.pedidos` | Admin | Badge de pedidos pendientes |
| `EntregaAsignada` | `chofer.{id}` | Chofer | Notificación de nueva entrega |

### 6.3 Implementación en Flutter

```dart
// Inicialización en main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => ChoferProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // ... otros providers
      ],
      child: MyApp(),
    ),
  );
}

// Conectar WebSocket después de login
class AuthProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();

  Future<void> login(String login, String password) async {
    // ... login normal ...

    // Conectar WebSocket con token
    await _wsService.connect(_token!);

    // Suscribirse según el rol
    if (isCliente) {
      _wsService.escucharPedido(clienteId, _onPedidoEvent);
    } else if (isChofer) {
      _wsService.escucharCanalChofer(choferId, _onChoferEvent);
    } else if (isAdmin) {
      _wsService.escucharAdminPedidos(_onAdminEvent);
    }
  }

  void _onPedidoEvent(dynamic data) {
    // Actualizar provider de pedidos
    // Mostrar notificación
  }
}
```

---

## 7. SISTEMA DE TRACKING GEOESPACIAL

### 7.1 Flujo de Tracking GPS

```
┌─────────────────────────────────────────────────────────────┐
│                    CHOFER EN RUTA                            │
│                                                              │
│  1. Chofer marca "Iniciar Ruta"                             │
│  2. App solicita permisos de ubicación                      │
│  3. App inicia Timer que cada 10-30 segundos:               │
│     - Obtiene ubicación GPS actual                          │
│     - Envía al backend vía API POST                         │
│     - Backend guarda en tabla `ubicaciones_tracking`        │
│     - Backend dispara evento `UbicacionActualizada`         │
│  4. WebSocket broadcast a canal `entrega.{id}`              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   CLIENTE VIENDO TRACKING                    │
│                                                              │
│  1. Cliente abre "Detalle de Pedido"                        │
│  2. Si estado = EN_RUTA, mostrar mapa                       │
│  3. TrackingProvider se suscribe a canal `entrega.{id}`     │
│  4. Cada vez que llega evento `UbicacionActualizada`:       │
│     - Actualizar pin del camión en el mapa                  │
│     - Recalcular distancia y tiempo estimado                │
│     - Mostrar velocidad del vehículo (opcional)             │
│  5. Cuando chofer marca "Llegó":                            │
│     - Notificación push al cliente                          │
│     - Detener tracking                                      │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Implementación de Tracking en Chofer

```dart
// lib/providers/chofer_provider.dart

void iniciarCompartirUbicacion(int entregaId) {
  // Iniciar timer para enviar ubicación cada 15 segundos
  _ubicacionTimer = Timer.periodic(Duration(seconds: 15), (_) {
    enviarUbicacionActual(entregaId);
  });
  notifyListeners();
}

Future<void> enviarUbicacionActual(int entregaId) async {
  try {
    // Obtener ubicación GPS
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Enviar al backend
    await _choferService.enviarUbicacion(
      entregaId,
      latitud: position.latitude,
      longitud: position.longitude,
      altitud: position.altitude,
      precision: position.accuracy,
      velocidad: position.speed * 3.6, // m/s a km/h
      rumbo: position.heading,
    );
  } catch (e) {
    print('Error enviando ubicación: $e');
  }
}

void detenerCompartirUbicacion() {
  _ubicacionTimer?.cancel();
  _ubicacionTimer = null;
  notifyListeners();
}
```

### 7.3 Implementación de Tracking en Cliente

```dart
// lib/screens/cliente/pedido_tracking_screen.dart

class PedidoTrackingScreen extends StatefulWidget {
  final Pedido pedido;

  @override
  _PedidoTrackingScreenState createState() => _PedidoTrackingScreenState();
}

class _PedidoTrackingScreenState extends State<PedidoTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    // Suscribirse a tracking si el pedido está en ruta
    if (widget.pedido.estado == EstadoPedido.EN_RUTA) {
      final trackingProvider = context.read<TrackingProvider>();
      trackingProvider.suscribirseATracking(widget.pedido.id);

      // Calcular distancia estimada
      if (widget.pedido.direccionEntrega != null) {
        trackingProvider.calcularDistancia(
          widget.pedido.id,
          widget.pedido.direccionEntrega!.latitud!,
          widget.pedido.direccionEntrega!.longitud!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking en Tiempo Real')),
      body: Consumer<TrackingProvider>(
        builder: (context, trackingProvider, _) {
          final ubicacion = trackingProvider.ubicacionActual;
          final distancia = trackingProvider.distanciaEstimada;

          if (ubicacion == null) {
            return Center(child: Text('Esperando ubicación del chofer...'));
          }

          return Column(
            children: [
              // Info de distancia y tiempo estimado
              if (distancia != null)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.location_on, size: 32),
                            Text(distancia.distanciaFormateada),
                            Text('Distancia', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.access_time, size: 32),
                            Text(distancia.tiempoFormateado),
                            Text('Tiempo estimado', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Mapa
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(ubicacion.latitud, ubicacion.longitud),
                    zoom: 15,
                  ),
                  markers: {
                    // Marcador del camión
                    Marker(
                      markerId: MarkerId('camion'),
                      position: LatLng(ubicacion.latitud, ubicacion.longitud),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Camión en camino',
                        snippet: 'Velocidad: ${ubicacion.velocidad?.toStringAsFixed(1) ?? 'N/A'} km/h',
                      ),
                    ),

                    // Marcador de la dirección de entrega
                    if (widget.pedido.direccionEntrega != null)
                      Marker(
                        markerId: MarkerId('destino'),
                        position: LatLng(
                          widget.pedido.direccionEntrega!.latitud!,
                          widget.pedido.direccionEntrega!.longitud!,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Tu ubicación',
                          snippet: widget.pedido.direccionEntrega!.direccion,
                        ),
                      ),
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    context.read<TrackingProvider>().desuscribirse();
    super.dispose();
  }
}
```

---

## 8. FLUJOS DE NAVEGACIÓN

### 8.1 Flujo del Cliente

```
LoginScreen
    ↓
HomeScreen (con BottomNavigationBar)
    ├─→ Tab: Catálogo
    │   └─→ ProductListScreen (ya existe)
    │       ├─→ ProductDetailScreen
    │       │   └─→ [Agregar al Carrito] → CarritoScreen
    │       └─→ [Ver Carrito Badge] → CarritoScreen
    │
    ├─→ Tab: Mi Carrito
    │   └─→ CarritoScreen
    │       ├─→ [Continuar Compra] → DireccionEntregaSeleccionScreen
    │       │   └─→ FechaHoraEntregaScreen
    │       │       └─→ ResumenPedidoScreen
    │       │           └─→ [Confirmar] → PedidoCreadoScreen
    │       │               └─→ PedidoDetalleScreen
    │       └─→ [Agregar más] → ProductListScreen
    │
    ├─→ Tab: Mis Pedidos
    │   └─→ PedidosHistorialScreen
    │       └─→ PedidoDetalleScreen
    │           ├─→ [Ver Tracking] → PedidoTrackingScreen (Mapa GPS)
    │           ├─→ [Extender Reserva] → (Dialog)
    │           └─→ [Ver Comprobante] → ComprobanteEntregaScreen
    │
    └─→ Tab: Perfil
        └─→ PerfilScreen
            ├─→ MisDireccionesScreen (ya existe parcialmente)
            ├─→ ConfiguracionScreen
            └─→ [Cerrar Sesión]
```

### 8.2 Flujo del Chofer

```
LoginScreen (mismo que cliente, pero con rol 'chofer')
    ↓
ChoferHomeScreen
    ├─→ Tab: Entregas del Día
    │   └─→ ChoferEntregasListScreen
    │       └─→ EntregaDetalleScreen
    │           ├─→ [Iniciar Ruta] → (Inicia GPS tracking)
    │           ├─→ [Navegar con GPS] → (Abre Google Maps/Waze)
    │           ├─→ [Marcar Llegada]
    │           ├─→ [Confirmar Entrega] → FirmaDigitalScreen
    │           │   └─→ (Captura firma + fotos)
    │           │       └─→ [Confirmar] → EntregaCompletadaScreen
    │           └─→ [Reportar Novedad] → ReportarNovedadScreen
    │               └─→ (Formulario con motivo + fotos)
    │
    ├─→ Tab: Historial
    │   └─→ ChoferHistorialScreen
    │       └─→ EntregaDetalleScreen (solo lectura)
    │
    └─→ Tab: Perfil
        └─→ PerfilChoferScreen
            ├─→ ConfiguracionScreen
            └─→ [Cerrar Sesión]
```

### 8.3 Flujo del Admin

```
LoginScreen (con rol 'admin')
    ↓
AdminHomeScreen (con BottomNavigationBar)
    ├─→ Tab: Dashboard
    │   └─→ AdminDashboardScreen
    │       ├─→ Card: Proformas Pendientes
    │       │   └─→ ProformasPendientesListScreen
    │       │       └─→ ProformaDetalleScreen
    │       │           ├─→ [Aprobar] → AprobarProformaDialog
    │       │           │   └─→ AsignarChoferCamionScreen
    │       │           │       └─→ [Confirmar] → (Pedido aprobado y asignado)
    │       │           └─→ [Rechazar] → RechazarProformaDialog
    │       │
    │       ├─→ Card: Pedidos en Proceso
    │       │   └─→ PedidosEnProcesoListScreen
    │       │       └─→ PedidoDetalleScreen
    │       │           └─→ [Reasignar Chofer]
    │       │
    │       └─→ Card: Entregas Activas
    │           └─→ EntregasActivasMapScreen (Mapa con todos los camiones)
    │
    ├─→ Tab: Pedidos
    │   └─→ AdminPedidosListScreen
    │       └─→ PedidoDetalleScreen
    │
    ├─→ Tab: Choferes
    │   └─→ ChoferesListScreen
    │       ├─→ ChoferDetalleScreen
    │       ├─→ ChoferFormScreen (crear/editar)
    │       └─→ [Eliminar]
    │
    ├─→ Tab: Camiones
    │   └─→ CamionesListScreen
    │       ├─→ CamionDetalleScreen
    │       ├─→ CamionFormScreen (crear/editar)
    │       └─→ [Eliminar]
    │
    └─→ Tab: Más
        └─→ AdminMenuScreen
            ├─→ ProductListScreen (ya existe)
            ├─→ ClientListScreen (ya existe)
            ├─→ ReportesScreen
            └─→ ConfiguracionScreen
```

### 8.4 Navegación Según Roles (AuthWrapper)

```dart
// lib/main.dart

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return LoginScreen();
        }

        // Redirigir según el rol del usuario
        final user = authProvider.user!;

        if (user.roles.contains('admin')) {
          return AdminHomeScreen();
        } else if (user.roles.contains('chofer')) {
          return ChoferHomeScreen();
        } else if (user.roles.contains('cliente')) {
          return ClienteHomeScreen();
        } else {
          // Rol desconocido
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Rol no reconocido'),
                  ElevatedButton(
                    onPressed: () => authProvider.logout(),
                    child: Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
```

---

## 9. EXTENSIONES DE API NECESARIAS

### 9.1 Endpoints Ya Documentados (Listo para Usar)

```
✅ POST   /api/app/pedidos                     - Crear proforma
✅ GET    /api/app/cliente/pedidos             - Historial de pedidos
✅ GET    /api/app/pedidos/{id}                - Detalle de pedido
✅ GET    /api/app/pedidos/{id}/estado         - Estado del pedido
✅ POST   /api/app/pedidos/{id}/extender-reservas - Extender reserva
✅ POST   /api/app/verificar-stock             - Verificar disponibilidad
✅ GET    /api/app/productos                   - Listar productos
✅ GET    /api/app/productos/{id}              - Detalle de producto
```

### 9.2 Nuevos Endpoints Necesarios en Backend

#### 9.2.1 Para Admin

```http
# Aprobar proforma
POST /api/admin/proformas/{id}/aprobar
Authorization: Bearer {token}
Content-Type: application/json

{
  "comentarios": "Aprobado. Preparar para mañana."
}

---

# Rechazar proforma
POST /api/admin/proformas/{id}/rechazar
Authorization: Bearer {token}
Content-Type: application/json

{
  "motivo": "Stock insuficiente para la fecha solicitada"
}

---

# Asignar chofer y camión
POST /api/admin/pedidos/{id}/asignar
Authorization: Bearer {token}
Content-Type: application/json

{
  "chofer_id": 3,
  "camion_id": 2,
  "fecha_programada": "2025-10-19 09:00:00"
}

---

# Dashboard de admin
GET /api/admin/pedidos?estado=PENDIENTE&page=1
Authorization: Bearer {token}

---

# CRUD Choferes
GET    /api/admin/choferes
POST   /api/admin/choferes
GET    /api/admin/choferes/{id}
PUT    /api/admin/choferes/{id}
DELETE /api/admin/choferes/{id}

---

# CRUD Camiones
GET    /api/admin/camiones
POST   /api/admin/camiones
GET    /api/admin/camiones/{id}
PUT    /api/admin/camiones/{id}
DELETE /api/admin/camiones/{id}

---

# Entregas activas (para mapa de tracking)
GET /api/admin/entregas/activas
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "pedido_numero": "PRO-20251018-0001",
      "chofer": { "id": 3, "nombre": "Carlos Pérez" },
      "camion": { "id": 2, "placa": "ABC-123" },
      "cliente": { "nombre": "Juan López" },
      "direccion_entrega": { "latitud": -16.5, "longitud": -68.11 },
      "ubicacion_actual": { "latitud": -16.52, "longitud": -68.13 },
      "estado": "EN_RUTA",
      "distancia_restante_km": 2.5,
      "tiempo_estimado_min": 15
    }
  ]
}
```

#### 9.2.2 Para Chofer

```http
# Ver entregas asignadas
GET /api/chofer/entregas?fecha=2025-10-18&estado=ASIGNADA
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "pedido": {
        "id": 1,
        "numero": "PRO-20251018-0001",
        "total": 127.13,
        "items_count": 2
      },
      "cliente": {
        "nombre": "Juan",
        "apellido": "López",
        "telefono": "987654321"
      },
      "direccion_entrega": {
        "direccion": "Av. Principal 123",
        "ciudad": "La Paz",
        "zona": "Centro",
        "referencia": "Frente al mercado",
        "latitud": -16.5000,
        "longitud": -68.1193
      },
      "camion": {
        "placa": "ABC-123",
        "marca": "Toyota"
      },
      "estado": "ASIGNADA",
      "fecha_programada": "2025-10-19T09:00:00.000000Z"
    }
  ]
}

---

# Detalle de entrega
GET /api/chofer/entregas/{id}
Authorization: Bearer {token}

---

# Iniciar ruta
POST /api/chofer/entregas/{id}/iniciar-ruta
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Ruta iniciada",
  "data": {
    "entrega_id": 1,
    "estado": "EN_CAMINO",
    "fecha_inicio": "2025-10-18T09:00:00.000000Z"
  }
}

---

# Actualizar estado de entrega
POST /api/chofer/entregas/{id}/actualizar-estado
Authorization: Bearer {token}
Content-Type: application/json

{
  "estado": "EN_RUTA",  // ASIGNADA, EN_CAMINO, LLEGO, ENTREGADO, NOVEDAD
  "observaciones": "Saliendo del almacén"
}

---

# Marcar llegada
POST /api/chofer/entregas/{id}/marcar-llegada
Authorization: Bearer {token}

---

# Confirmar entrega con firma
POST /api/chofer/entregas/{id}/confirmar-entrega
Authorization: Bearer {token}
Content-Type: multipart/form-data

firma: [imagen base64 o archivo]
foto_1: [archivo]
foto_2: [archivo]
observaciones: "Entregado en buen estado"

Response:
{
  "success": true,
  "message": "Entrega confirmada exitosamente",
  "data": {
    "entrega_id": 1,
    "estado": "ENTREGADO",
    "fecha_entrega": "2025-10-18T10:30:00.000000Z",
    "firma_url": "https://storage.com/firmas/123.jpg",
    "fotos_urls": [
      "https://storage.com/entregas/foto1.jpg",
      "https://storage.com/entregas/foto2.jpg"
    ]
  }
}

---

# Reportar novedad
POST /api/chofer/entregas/{id}/reportar-novedad
Authorization: Bearer {token}
Content-Type: application/json

{
  "motivo": "CLIENTE_NO_ESTA",  // CLIENTE_NO_ESTA, DIRECCION_INCORRECTA, PRODUCTO_DAÑADO, OTRO
  "descripcion": "Nadie abrió la puerta después de tocar varias veces",
  "fotos": [
    "base64...",
    "base64..."
  ]
}

---

# Enviar ubicación GPS en tiempo real
POST /api/chofer/entregas/{id}/ubicacion
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitud": -16.5000,
  "longitud": -68.1193,
  "altitud": 3650.5,
  "precision": 10.5,      // metros
  "velocidad": 45.2,      // km/h
  "rumbo": 180.5,         // grados
  "evento": "en_ruta"     // inicio_ruta, en_ruta, llegada, entrega
}

Response:
{
  "success": true,
  "message": "Ubicación registrada"
}

---

# Historial de entregas del chofer
GET /api/chofer/historial?page=1&fecha_desde=2025-10-01&fecha_hasta=2025-10-18
Authorization: Bearer {token}
```

#### 9.2.3 Para Tracking

```http
# Obtener ubicaciones de una entrega
GET /api/tracking/entregas/{entrega_id}/ubicaciones
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "entrega_id": 1,
    "ubicacion_actual": {
      "latitud": -16.5200,
      "longitud": -68.1300,
      "velocidad": 40.5,
      "timestamp": "2025-10-18T10:25:30.000000Z"
    },
    "historial": [
      {
        "latitud": -16.5100,
        "longitud": -68.1250,
        "velocidad": 35.0,
        "timestamp": "2025-10-18T10:24:45.000000Z"
      },
      {
        "latitud": -16.5000,
        "longitud": -68.1200,
        "velocidad": 30.0,
        "timestamp": "2025-10-18T10:24:00.000000Z"
      }
    ]
  }
}

---

# Calcular distancia y tiempo estimado de llegada
POST /api/tracking/entregas/{entrega_id}/calcular-eta
Authorization: Bearer {token}
Content-Type: application/json

{
  "lat_destino": -16.5000,
  "lng_destino": -68.1193
}

Response:
{
  "success": true,
  "data": {
    "distancia_metros": 2500,
    "distancia_formateada": "2.5 km",
    "tiempo_estimado_minutos": 15,
    "tiempo_formateado": "15 min",
    "velocidad_promedio_kmh": 35.5
  }
}
```

### 9.3 Eventos de WebSocket/Broadcasting

```php
// Backend Laravel - Eventos a implementar

namespace App\Events;

// Evento cuando se aprueba una proforma
class ProformaAprobada implements ShouldBroadcast
{
    public $proforma;

    public function broadcastOn() {
        return [
            new PrivateChannel('pedido.' . $this->proforma->id),
            new PrivateChannel('admin.pedidos'),
        ];
    }
}

// Evento cuando se asigna un chofer
class PedidoAsignado implements ShouldBroadcast
{
    public $pedido;
    public $chofer;
    public $camion;

    public function broadcastOn() {
        return [
            new PrivateChannel('pedido.' . $this->pedido->id),
            new PrivateChannel('chofer.' . $this->chofer->id),
        ];
    }
}

// Evento cuando cambia el estado del pedido
class EstadoPedidoCambiado implements ShouldBroadcast
{
    public $pedido;
    public $estadoAnterior;
    public $estadoNuevo;

    public function broadcastOn() {
        return new PrivateChannel('pedido.' . $this->pedido->id);
    }
}

// Evento cuando se actualiza la ubicación GPS
class UbicacionActualizada implements ShouldBroadcast
{
    public $entrega;
    public $ubicacion;

    public function broadcastOn() {
        return new PrivateChannel('entrega.' . $this->entrega->id);
    }
}

// Evento cuando el chofer inicia ruta
class ChoferEnCamino implements ShouldBroadcast
{
    public $entrega;

    public function broadcastOn() {
        return new PrivateChannel('pedido.' . $this->entrega->pedido_id);
    }
}

// Evento cuando el chofer llega
class ChoferLlego implements ShouldBroadcast
{
    public $entrega;

    public function broadcastOn() {
        return new PrivateChannel('pedido.' . $this->entrega->pedido_id);
    }
}

// Evento cuando se entrega el pedido
class PedidoEntregado implements ShouldBroadcast
{
    public $pedido;
    public $entrega;

    public function broadcastOn() {
        return [
            new PrivateChannel('pedido.' . $this->pedido->id),
            new PrivateChannel('admin.pedidos'),
        ];
    }
}

// Evento cuando hay una novedad
class NovedadReportada implements ShouldBroadcast
{
    public $entrega;
    public $motivo;

    public function broadcastOn() {
        return [
            new PrivateChannel('pedido.' . $this->entrega->pedido_id),
            new PrivateChannel('admin.pedidos'),
        ];
    }
}
```

---

## 10. PLAN DE IMPLEMENTACIÓN

### FASE 1: CLIENTE - MÓDULO DE PEDIDOS (Semana 1-2)

#### Sprint 1.1: Carrito de Compras
- [ ] Crear modelo `Carrito` y `CarritoItem`
- [ ] Crear `CarritoProvider`
- [ ] Implementar `CarritoScreen` (lista de items, totales)
- [ ] Agregar botón "Agregar al Carrito" en `ProductDetailScreen`
- [ ] Agregar badge de cantidad en BottomNavigationBar
- [ ] Implementar verificación de stock antes de crear pedido

#### Sprint 1.2: Crear Proforma
- [ ] Crear modelos `Pedido`, `PedidoItem`, `EstadoPedido`
- [ ] Crear `PedidoService` con método `crearPedido()`
- [ ] Implementar `DireccionEntregaSeleccionScreen`
- [ ] Implementar `FechaHoraEntregaScreen` (date/time picker)
- [ ] Implementar `ResumenPedidoScreen`
- [ ] Implementar `PedidoCreadoScreen` (confirmación)
- [ ] Integrar API `POST /api/app/pedidos`

#### Sprint 1.3: Historial y Detalle
- [ ] Crear `PedidoProvider`
- [ ] Implementar `PedidosHistorialScreen` (lista paginada)
- [ ] Implementar `PedidoDetalleScreen`
- [ ] Mostrar timeline de estados del pedido
- [ ] Integrar API `GET /api/app/cliente/pedidos`
- [ ] Integrar API `GET /api/app/pedidos/{id}`
- [ ] Implementar pull-to-refresh

#### Sprint 1.4: Tracking Básico
- [ ] Crear modelo `UbicacionTracking`
- [ ] Crear `TrackingProvider`
- [ ] Implementar `PedidoTrackingScreen` con Google Maps
- [ ] Mostrar pin del camión y pin del destino
- [ ] Mostrar información del chofer y camión asignado
- [ ] Implementar polling cada 30 segundos (temporal, antes de WebSocket)

### FASE 2: NOTIFICACIONES Y TIEMPO REAL (Semana 3)

#### Sprint 2.1: Notificaciones Push
- [ ] Configurar Firebase Cloud Messaging
- [ ] Crear `NotificationService`
- [ ] Crear `NotificationProvider`
- [ ] Solicitar permisos de notificaciones
- [ ] Enviar FCM token al backend
- [ ] Manejar notificaciones en foreground/background
- [ ] Mostrar notificaciones locales

#### Sprint 2.2: WebSockets (Laravel Echo)
- [ ] Configurar Laravel Echo en Flutter
- [ ] Crear `WebSocketService`
- [ ] Conectar con token después de login
- [ ] Suscribirse a canal `pedido.{id}` para clientes
- [ ] Actualizar `TrackingProvider` para usar WebSocket en vez de polling
- [ ] Actualizar `PedidoProvider` para escuchar eventos de cambio de estado
- [ ] Probar eventos: `ProformaAprobada`, `EstadoPedidoCambiado`, `UbicacionActualizada`

### FASE 3: ROL CHOFER (Semana 4-5)

#### Sprint 3.1: Backend - Endpoints de Chofer
- [ ] Crear endpoints de chofer en backend (ver sección 9.2.2)
- [ ] Implementar lógica de actualización de estados
- [ ] Implementar almacenamiento de ubicaciones GPS
- [ ] Implementar upload de firma digital y fotos
- [ ] Configurar eventos de broadcasting para chofer
- [ ] Testing de endpoints

#### Sprint 3.2: App - Vista de Entregas
- [ ] Crear modelos `Chofer`, `Camion`, `Entrega`
- [ ] Crear `ChoferService`
- [ ] Crear `ChoferProvider`
- [ ] Implementar `ChoferHomeScreen`
- [ ] Implementar `ChoferEntregasListScreen`
- [ ] Implementar `EntregaDetalleScreen`
- [ ] Mostrar información de cliente y productos

#### Sprint 3.3: App - Tracking GPS del Chofer
- [ ] Solicitar permisos de ubicación en tiempo real
- [ ] Implementar función "Iniciar Ruta"
- [ ] Implementar envío automático de GPS cada 15-30 segundos
- [ ] Implementar función "Marcar Llegada"
- [ ] Mostrar indicador cuando GPS está activo
- [ ] Probar en dispositivo real (no emulador)

#### Sprint 3.4: App - Confirmación de Entrega
- [ ] Implementar `FirmaDigitalScreen` (signature pad)
- [ ] Implementar captura de fotos de comprobante
- [ ] Implementar `ReportarNovedadScreen`
- [ ] Integrar API de confirmación de entrega
- [ ] Implementar `EntregaCompletadaScreen`
- [ ] Implementar historial de entregas del chofer

#### Sprint 3.5: App - Navegación GPS
- [ ] Integrar con Google Maps (url_launcher)
- [ ] Integrar con Waze (url_launcher)
- [ ] Mostrar botón "Navegar" que abre app de mapas
- [ ] Pasar coordenadas de la dirección de entrega

### FASE 4: ROL ADMIN (Semana 6-7)

#### Sprint 4.1: Backend - Endpoints de Admin
- [ ] Crear endpoints de admin (ver sección 9.2.1)
- [ ] Implementar lógica de aprobar/rechazar proformas
- [ ] Implementar lógica de asignación de chofer/camión
- [ ] CRUD de choferes
- [ ] CRUD de camiones
- [ ] Endpoint de entregas activas para mapa
- [ ] Testing de endpoints

#### Sprint 4.2: App - Dashboard de Admin
- [ ] Crear `AdminService`
- [ ] Crear `AdminProvider`
- [ ] Implementar `AdminHomeScreen`
- [ ] Implementar `AdminDashboardScreen` con cards:
  - Proformas pendientes de aprobación
  - Pedidos en proceso
  - Entregas activas (con número)
- [ ] Implementar navegación a cada sección

#### Sprint 4.3: App - Gestión de Proformas
- [ ] Implementar `ProformasPendientesListScreen`
- [ ] Implementar `ProformaDetalleScreen` (admin view)
- [ ] Implementar `AprobarProformaDialog`
- [ ] Implementar `AsignarChoferCamionScreen`
- [ ] Implementar `RechazarProformaDialog`
- [ ] Integrar APIs de aprobar/rechazar/asignar

#### Sprint 4.4: App - Gestión de Choferes y Camiones
- [ ] Implementar `ChoferesListScreen`
- [ ] Implementar `ChoferFormScreen` (crear/editar)
- [ ] Implementar `ChoferDetalleScreen`
- [ ] Implementar `CamionesListScreen`
- [ ] Implementar `CamionFormScreen` (crear/editar)
- [ ] Implementar `CamionDetalleScreen`
- [ ] Integrar APIs CRUD

#### Sprint 4.5: App - Tracking Múltiple
- [ ] Implementar `EntregasActivasMapScreen`
- [ ] Mostrar múltiples markers en mapa (uno por camión activo)
- [ ] Diferenciar markers por color según estado
- [ ] Mostrar info window con datos de la entrega
- [ ] Actualizar en tiempo real vía WebSocket
- [ ] Implementar filtros (por chofer, por zona, etc.)

### FASE 5: PULIDO Y OPTIMIZACIONES (Semana 8)

#### Sprint 5.1: UX/UI
- [ ] Diseño consistente con tema de la app
- [ ] Animaciones y transiciones
- [ ] Loading states y skeleton screens
- [ ] Error states con retry
- [ ] Empty states
- [ ] Iconografía coherente

#### Sprint 5.2: Performance
- [ ] Optimizar queries al backend (eager loading)
- [ ] Implementar caché local con Hive
- [ ] Lazy loading de imágenes
- [ ] Optimizar WebSocket reconnection
- [ ] Reducir tamaño de payloads JSON

#### Sprint 5.3: Testing
- [ ] Unit tests para providers
- [ ] Unit tests para services
- [ ] Widget tests para pantallas principales
- [ ] Integration tests para flujos completos
- [ ] Testing en dispositivos reales (Android/iOS)

#### Sprint 5.4: DevOps
- [ ] Configurar CI/CD (GitHub Actions o similar)
- [ ] Configurar ambientes (dev, staging, prod)
- [ ] Configurar Firebase para cada ambiente
- [ ] Versioning de la app
- [ ] Preparar para release

---

## 11. CONSIDERACIONES TÉCNICAS

### 11.1 Seguridad

- **Autenticación:** JWT tokens con refresh automático
- **Permisos:** Verificar permisos en backend para cada endpoint
- **WebSocket:** Canales privados autenticados con token
- **Ubicación GPS:** Solo enviar cuando hay entrega activa
- **Firma Digital:** Validar formato y tamaño antes de enviar

### 11.2 Offline Support (Futuro)

- Guardar carrito localmente con Hive
- Sincronizar cuando vuelva conexión
- Mostrar datos cacheados cuando no hay internet
- Queue de ubicaciones GPS para enviar cuando reconecte

### 11.3 Escalabilidad

- Backend preparado para múltiples distribuidoras (multi-tenant)
- Uso de queues para procesos pesados (notificaciones, emails)
- CDN para imágenes de productos
- Database indexing en campos críticos (cliente_id, chofer_id, estado)

### 11.4 Monitoreo

- Logs de errores (Sentry)
- Analytics (Firebase Analytics)
- Crashlytics
- Performance monitoring

---

## 12. TECNOLOGÍAS RESUMIDAS

### Backend (Laravel)
- Laravel 10+
- Sanctum (API tokens)
- Broadcasting (WebSockets)
- Pusher o Laravel WebSocket
- Firebase Admin SDK (Push notifications)
- MySQL/PostgreSQL

### Frontend (Flutter)
- Flutter 3.x
- Provider (State management)
- Dio (HTTP client)
- Laravel Echo (WebSockets)
- Firebase Messaging (Push)
- Google Maps / Flutter Map
- Geolocator (GPS)
- Signature pad (Firma digital)
- Image picker (Fotos)
- Hive (Storage local)

---

## 13. CONCLUSIÓN

Este documento establece la arquitectura completa para escalar el sistema de distribuidora a un sistema multi-rol funcional que cubre:

1. **Cliente:** Catálogo → Carrito → Pedido → Tracking en tiempo real
2. **Chofer:** Entregas asignadas → Navegación GPS → Actualización de estado → Confirmación con firma
3. **Admin:** Dashboard → Aprobar proformas → Asignar entregas → Tracking múltiple → Gestión de recursos

La implementación está planificada en 5 fases (8 semanas) con sprints bien definidos. La arquitectura es escalable, segura y moderna, utilizando las mejores prácticas de Flutter y Laravel.

**Siguiente paso:** Revisar este documento, ajustar prioridades si es necesario, y comenzar con la Fase 1 - Sprint 1.1 (Carrito de Compras).

---

**Documento creado:** 2025-10-18
**Versión:** 1.0
**Autor:** Claude AI - Asistente de Arquitectura
**Proyecto:** Sistema de Distribuidora Multi-Rol
