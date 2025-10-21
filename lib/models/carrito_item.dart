import 'product.dart';

class CarritoItem {
  final Product producto;
  final double cantidad;
  final double precioUnitario;
  final String? observaciones;

  CarritoItem({
    required this.producto,
    required this.cantidad,
    double? precioUnitario,
    this.observaciones,
  }) : precioUnitario = precioUnitario ?? producto.precioVenta ?? 0.0;

  // Cálculo del subtotal
  double get subtotal {
    return precioUnitario * cantidad;
  }

  // Verificar si el producto tiene stock suficiente
  bool tieneStockSuficiente() {
    // Esta lógica se refinará cuando tengamos stock_total en Product
    // Por ahora retornamos true
    return true;
  }

  // Crear copia con modificaciones
  CarritoItem copyWith({
    Product? producto,
    double? cantidad,
    double? precioUnitario,
    String? observaciones,
  }) {
    return CarritoItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'producto_id': producto.id,
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      'observaciones': observaciones,
    };
  }

  // Crear desde JSON (para guardar localmente con Hive en el futuro)
  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      producto: Product.fromJson(json['producto']),
      cantidad: json['cantidad']?.toDouble() ?? 1.0,
      precioUnitario: json['precio_unitario']?.toDouble(),
      observaciones: json['observaciones'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarritoItem && other.producto.id == producto.id;
  }

  @override
  int get hashCode => producto.id.hashCode;
}
