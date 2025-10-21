import 'product.dart';

class PedidoItem {
  final int id;
  final int pedidoId;
  final int productoId;
  final Product? producto;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? observaciones;

  PedidoItem({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.observaciones,
  });

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      id: json['id'] as int,
      pedidoId: json['pedido_id'] as int,
      productoId: json['producto_id'] as int,
      producto: json['producto'] != null
          ? Product.fromJson(json['producto'] as Map<String, dynamic>)
          : null,
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'producto': producto?.toJson(),
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      'observaciones': observaciones,
    };
  }

  PedidoItem copyWith({
    int? id,
    int? pedidoId,
    int? productoId,
    Product? producto,
    double? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? observaciones,
  }) {
    return PedidoItem(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
