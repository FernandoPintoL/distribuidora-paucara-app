import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class PedidoProvider with ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();

  // Estado
  List<Pedido> _pedidos = [];
  Pedido? _pedidoActual;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Paginación
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalItems = 0;
  int _perPage = 15;

  // Filtros
  EstadoPedido? _filtroEstado;
  DateTime? _filtroFechaDesde;
  DateTime? _filtroFechaHasta;

  // Getters
  List<Pedido> get pedidos => _pedidos;
  Pedido? get pedidoActual => _pedidoActual;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _hasMorePages;
  int get totalItems => _totalItems;
  EstadoPedido? get filtroEstado => _filtroEstado;
  DateTime? get filtroFechaDesde => _filtroFechaDesde;
  DateTime? get filtroFechaHasta => _filtroFechaHasta;

  /// Cargar historial de pedidos (página 1)
  Future<void> loadPedidos({
    EstadoPedido? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _filtroEstado = estado;
    _filtroFechaDesde = fechaDesde;
    _filtroFechaHasta = fechaHasta;

    if (refresh) {
      // Si es refresh, no mostramos loading inicial
      _isLoading = false;
    }

    notifyListeners();

    try {
      final response = await _pedidoService.getPedidosCliente(
        page: _currentPage,
        perPage: _perPage,
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      if (response.success && response.data != null) {
        _pedidos = response.data!.data;
        _hasMorePages = response.data!.hasMorePages;
        _totalItems = response.data!.total;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Error al cargar pedidos';
        _pedidos = [];
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _pedidos = [];
      debugPrint('Error loading pedidos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar más pedidos (siguiente página)
  Future<void> loadMorePedidos() async {
    if (_isLoadingMore || !_hasMorePages || _isLoading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final response = await _pedidoService.getPedidosCliente(
        page: nextPage,
        perPage: _perPage,
        estado: _filtroEstado,
        fechaDesde: _filtroFechaDesde,
        fechaHasta: _filtroFechaHasta,
      );

      if (response.success && response.data != null) {
        // Agregar nuevos pedidos a la lista existente
        _pedidos.addAll(response.data!.data);
        _hasMorePages = response.data!.hasMorePages;
        _currentPage = nextPage;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Error al cargar más pedidos';
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      debugPrint('Error loading more pedidos: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Obtener detalle completo de un pedido
  Future<void> loadPedido(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _pedidoService.getPedido(id);

      if (response.success && response.data != null) {
        _pedidoActual = response.data;
        _errorMessage = null;

        // Actualizar pedido en la lista si existe
        final index = _pedidos.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pedidos[index] = response.data!;
        }
      } else {
        _errorMessage = response.message ?? 'Error al cargar el pedido';
        _pedidoActual = null;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _pedidoActual = null;
      debugPrint('Error loading pedido detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refrescar solo el estado de un pedido (lightweight)
  Future<void> refreshEstadoPedido(int id) async {
    try {
      final response = await _pedidoService.getEstadoPedido(id);

      if (response.success && response.data != null) {
        final nuevoEstado = EstadoInfo.fromString(
          response.data!['estado'] as String,
        );

        // Actualizar en la lista
        final index = _pedidos.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pedidos[index] = _pedidos[index].copyWith(estado: nuevoEstado);
        }

        // Actualizar pedido actual si es el mismo
        if (_pedidoActual?.id == id) {
          _pedidoActual = _pedidoActual!.copyWith(estado: nuevoEstado);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing estado: $e');
    }
  }

  /// Extender reservas de stock de un pedido
  Future<bool> extenderReserva(int pedidoId) async {
    try {
      _errorMessage = null;

      final response = await _pedidoService.extenderReservas(pedidoId);

      if (response.success) {
        // Recargar el pedido para obtener las nuevas fechas de expiración
        await loadPedido(pedidoId);
        return true;
      } else {
        _errorMessage = response.message ?? 'Error al extender reservas';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      notifyListeners();
      debugPrint('Error extending reserva: $e');
      return false;
    }
  }

  /// Filtrar pedidos localmente por estado
  List<Pedido> getPedidosPorEstado(EstadoPedido estado) {
    return _pedidos.where((p) => p.estado == estado).toList();
  }

  /// Obtener pedidos pendientes
  List<Pedido> get pedidosPendientes {
    return getPedidosPorEstado(EstadoPedido.PENDIENTE);
  }

  /// Obtener pedidos aprobados
  List<Pedido> get pedidosAprobados {
    return getPedidosPorEstado(EstadoPedido.APROBADA);
  }

  /// Obtener pedidos en proceso (preparando, en camión, en ruta)
  List<Pedido> get pedidosEnProceso {
    return _pedidos.where((p) =>
      p.estado == EstadoPedido.PREPARANDO ||
      p.estado == EstadoPedido.EN_CAMION ||
      p.estado == EstadoPedido.EN_RUTA ||
      p.estado == EstadoPedido.LLEGO
    ).toList();
  }

  /// Obtener pedidos entregados
  List<Pedido> get pedidosEntregados {
    return getPedidosPorEstado(EstadoPedido.ENTREGADO);
  }

  /// Obtener pedidos con novedad
  List<Pedido> get pedidosConNovedad {
    return getPedidosPorEstado(EstadoPedido.NOVEDAD);
  }

  /// Aplicar filtro de estado
  Future<void> aplicarFiltroEstado(EstadoPedido? estado) async {
    await loadPedidos(
      estado: estado,
      fechaDesde: _filtroFechaDesde,
      fechaHasta: _filtroFechaHasta,
    );
  }

  /// Aplicar filtro de fechas
  Future<void> aplicarFiltroFechas(DateTime? desde, DateTime? hasta) async {
    await loadPedidos(
      estado: _filtroEstado,
      fechaDesde: desde,
      fechaHasta: hasta,
    );
  }

  /// Limpiar filtros
  Future<void> limpiarFiltros() async {
    await loadPedidos();
  }

  /// Limpiar error
  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar pedido actual
  void limpiarPedidoActual() {
    _pedidoActual = null;
    notifyListeners();
  }

  /// Resetear provider
  void reset() {
    _pedidos = [];
    _pedidoActual = null;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMorePages = true;
    _totalItems = 0;
    _filtroEstado = null;
    _filtroFechaDesde = null;
    _filtroFechaHasta = null;
    notifyListeners();
  }
}
