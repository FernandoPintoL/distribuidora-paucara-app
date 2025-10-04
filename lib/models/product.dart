class Product {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final Category? categoria;
  final Brand? marca;
  final Supplier? proveedor;
  final UnitMeasure? unidadMedida;
  final bool activo;
  final double? precioCompra;
  final double? precioVenta;
  final int? stockMinimo;
  final int? stockMaximo;
  final List<ProductImage>? imagenes;
  final List<String>? codigosBarra;

  Product({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    this.categoria,
    this.marca,
    this.proveedor,
    this.unidadMedida,
    required this.activo,
    this.precioCompra,
    this.precioVenta,
    this.stockMinimo,
    this.stockMaximo,
    this.imagenes,
    this.codigosBarra,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'] != null
          ? Category.fromJson(json['categoria'])
          : null,
      marca: json['marca'] != null ? Brand.fromJson(json['marca']) : null,
      proveedor: json['proveedor'] != null
          ? Supplier.fromJson(json['proveedor'])
          : null,
      unidadMedida: json['unidad_medida'] != null
          ? UnitMeasure.fromJson(json['unidad_medida'])
          : null,
      activo: json['activo'] ?? true,
      precioCompra: json['precio_compra']?.toDouble(),
      precioVenta: json['precio_venta']?.toDouble(),
      stockMinimo: json['stock_minimo'],
      stockMaximo: json['stock_maximo'],
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List)
                .map((i) => ProductImage.fromJson(i))
                .toList()
          : null,
      codigosBarra: json['codigos_barra'] != null
          ? List<String>.from(json['codigos_barra'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'categoria': categoria?.toJson(),
      'marca': marca?.toJson(),
      'proveedor': proveedor?.toJson(),
      'unidad_medida': unidadMedida?.toJson(),
      'activo': activo,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'stock_minimo': stockMinimo,
      'stock_maximo': stockMaximo,
      'imagenes': imagenes?.map((i) => i.toJson()).toList(),
      'codigos_barra': codigosBarra,
    };
  }
}

class Category {
  final int id;
  final String nombre;

  Category({required this.id, required this.nombre});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], nombre: json['nombre']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}

class Brand {
  final int id;
  final String nombre;

  Brand({required this.id, required this.nombre});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json['id'], nombre: json['nombre']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}

class Supplier {
  final int id;
  final String nombre;
  final String? razonSocial;

  Supplier({required this.id, required this.nombre, this.razonSocial});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      nombre: json['nombre'],
      razonSocial: json['razon_social'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'razon_social': razonSocial};
  }
}

class UnitMeasure {
  final int id;
  final String nombre;

  UnitMeasure({required this.id, required this.nombre});

  factory UnitMeasure.fromJson(Map<String, dynamic> json) {
    return UnitMeasure(id: json['id'], nombre: json['nombre']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}

class ProductImage {
  final String url;
  final int orden;

  ProductImage({required this.url, required this.orden});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(url: json['url'], orden: json['orden']);
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'orden': orden};
  }
}
