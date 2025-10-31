import 'package:flutter/widgets.dart';
import '../models/carrito.dart';
import '../models/carrito_item.dart';
import '../models/product.dart';

class CarritoProvider with ChangeNotifier {
  Carrito _carrito = Carrito(items: []);
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Carrito get carrito => _carrito;
  List<CarritoItem> get items => _carrito.items;
  int get cantidadItems => _carrito.cantidadItems;
  int get cantidadProductos => _carrito.cantidadProductos;
  double get subtotal => _carrito.subtotal;
  double get impuesto => _carrito.impuesto;
  double get total => _carrito.total;
  bool get isEmpty => _carrito.isEmpty;
  bool get isNotEmpty => _carrito.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Agregar producto al carrito
  void agregarProducto(
    Product producto, {
    double cantidad = 1.0,
    String? observaciones,
  }) {
    _errorMessage = null;

    // Verificar si el producto ya está en el carrito
    final itemExistente = _carrito.getItemByProductoId(producto.id);

    List<CarritoItem> nuevosItems = List.from(_carrito.items);

    if (itemExistente != null) {
      // Si ya existe, actualizar la cantidad
      final index = nuevosItems.indexWhere(
        (item) => item.producto.id == producto.id,
      );
      nuevosItems[index] = itemExistente.copyWith(
        cantidad: itemExistente.cantidad + cantidad,
      );
    } else {
      // Si no existe, agregarlo
      nuevosItems.add(
        CarritoItem(
          producto: producto,
          cantidad: cantidad,
          observaciones: observaciones,
        ),
      );
    }

    _carrito = _carrito.copyWith(items: nuevosItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Actualizar cantidad de un producto
  void actualizarCantidad(int productoId, double nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      eliminarProducto(productoId);
      return;
    }

    final itemExistente = _carrito.getItemByProductoId(productoId);
    if (itemExistente == null) return;

    List<CarritoItem> nuevosItems = List.from(_carrito.items);
    final index = nuevosItems.indexWhere(
      (item) => item.producto.id == productoId,
    );

    nuevosItems[index] = itemExistente.copyWith(cantidad: nuevaCantidad);

    _carrito = _carrito.copyWith(items: nuevosItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Incrementar cantidad de un producto
  void incrementarCantidad(int productoId, {double incremento = 1.0}) {
    final itemExistente = _carrito.getItemByProductoId(productoId);
    if (itemExistente == null) return;

    actualizarCantidad(productoId, itemExistente.cantidad + incremento);
  }

  // Decrementar cantidad de un producto
  void decrementarCantidad(int productoId, {double decremento = 1.0}) {
    final itemExistente = _carrito.getItemByProductoId(productoId);
    if (itemExistente == null) return;

    final nuevaCantidad = itemExistente.cantidad - decremento;
    if (nuevaCantidad <= 0) {
      eliminarProducto(productoId);
    } else {
      actualizarCantidad(productoId, nuevaCantidad);
    }
  }

  // Eliminar producto del carrito
  void eliminarProducto(int productoId) {
    List<CarritoItem> nuevosItems = _carrito.items
        .where((item) => item.producto.id != productoId)
        .toList();

    _carrito = _carrito.copyWith(items: nuevosItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Actualizar observaciones de un item
  void actualizarObservaciones(int productoId, String observaciones) {
    final itemExistente = _carrito.getItemByProductoId(productoId);
    if (itemExistente == null) return;

    List<CarritoItem> nuevosItems = List.from(_carrito.items);
    final index = nuevosItems.indexWhere(
      (item) => item.producto.id == productoId,
    );

    nuevosItems[index] = itemExistente.copyWith(observaciones: observaciones);

    _carrito = _carrito.copyWith(items: nuevosItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Limpiar carrito
  void limpiarCarrito() {
    _carrito = Carrito(items: []);
    _errorMessage = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Verificar si un producto está en el carrito
  bool tieneProducto(int productoId) {
    return _carrito.tieneProducto(productoId);
  }

  // Obtener cantidad de un producto en el carrito
  double getCantidadProducto(int productoId) {
    final item = _carrito.getItemByProductoId(productoId);
    return item?.cantidad ?? 0.0;
  }

  // Verificar stock disponible antes de crear pedido
  Future<bool> verificarStock() async {
    if (_carrito.isEmpty) {
      _errorMessage = 'El carrito está vacío';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // Preparar items para verificación
      final itemsParaVerificar = _carrito.items
          .map(
            (item) => {
              'producto_id': item.producto.id,
              'cantidad': item.cantidad,
            },
          )
          .toList();

      // TODO: Implementar cuando el endpoint de verificación esté disponible
      // final response = await _productService.verificarStock(itemsParaVerificar);

      // Por ahora retornamos true
      debugPrint(
        'Verificando stock para ${itemsParaVerificar.length} productos...',
      );

      // Simulamos una verificación exitosa
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _errorMessage = 'Error al verificar stock: ${e.toString()}';
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Limpiar mensaje de error
  void limpiarError() {
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Obtener items formateados para crear pedido
  List<Map<String, dynamic>> getItemsParaPedido() {
    return _carrito.toItemsForPedido();
  }
}
