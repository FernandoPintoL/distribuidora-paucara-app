import 'carrito_item.dart';

class Carrito {
  final List<CarritoItem> items;

  Carrito({this.items = const []});

  // Cálculos
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get impuesto {
    // 13% de impuesto (ajustar según tu país)
    return subtotal * 0.13;
  }

  double get total {
    return subtotal + impuesto;
  }

  int get cantidadItems {
    return items.length;
  }

  int get cantidadProductos {
    return items.fold(0, (sum, item) => sum + item.cantidad.toInt());
  }

  bool get isEmpty {
    return items.isEmpty;
  }

  bool get isNotEmpty {
    return items.isNotEmpty;
  }

  // Métodos auxiliares
  CarritoItem? getItemByProductoId(int productoId) {
    try {
      return items.firstWhere((item) => item.producto.id == productoId);
    } catch (e) {
      return null;
    }
  }

  bool tieneProducto(int productoId) {
    return items.any((item) => item.producto.id == productoId);
  }

  // Crear copia con nuevos items
  Carrito copyWith({List<CarritoItem>? items}) {
    return Carrito(
      items: items ?? this.items,
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'impuesto': impuesto,
      'total': total,
    };
  }

  // Convertir items para crear pedido (formato API)
  List<Map<String, dynamic>> toItemsForPedido() {
    return items.map((item) => {
      'producto_id': item.producto.id,
      'cantidad': item.cantidad,
      'precio_unitario': item.precioUnitario,
    }).toList();
  }
}
