import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../services/services.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasMorePages = true;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMorePages => _hasMorePages;

  Future<bool> loadProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool? active,
    bool append = false,
  }) async {
    if (!append) {
      _isLoading = true;
      _products = [];
      _currentPage = 1;
    }
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _productService.getProducts(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
        brandId: brandId,
        supplierId: supplierId,
        active: active,
      );

      if (response.success && response.data != null) {
        if (append) {
          _products.addAll(response.data!.data);
        } else {
          _products = response.data!.data;
        }

        _currentPage = response.data!.currentPage;
        _totalPages = (response.data!.total / perPage).ceil();
        _totalItems = response.data!.total;
        _hasMorePages = _currentPage < _totalPages;
        _errorMessage = null;

        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> loadMoreProducts({
    String? search,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool? active,
  }) async {
    if (!_hasMorePages || _isLoading) return false;

    return loadProducts(
      page: _currentPage + 1,
      search: search,
      categoryId: categoryId,
      brandId: brandId,
      supplierId: supplierId,
      active: active,
      append: true,
    );
  }

  Future<List<Product>> searchProducts(String query, {int limit = 10}) async {
    try {
      final response = await _productService.searchProducts(
        query,
        limit: limit,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Product?> getProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _productService.getProduct(id);

      if (response.success && response.data != null) {
        _errorMessage = null;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return response.data;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return null;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> createProduct({
    required String nombre,
    required String codigo,
    String? descripcion,
    int? categoriaId,
    int? marcaId,
    int? proveedorId,
    int? unidadMedidaId,
    double? precioCompra,
    double? precioVenta,
    int? stockMinimo,
    int? stockMaximo,
    bool activo = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _productService.createProduct(
        nombre: nombre,
        codigo: codigo,
        descripcion: descripcion,
        categoriaId: categoriaId,
        marcaId: marcaId,
        proveedorId: proveedorId,
        unidadMedidaId: unidadMedidaId,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
        stockMinimo: stockMinimo,
        stockMaximo: stockMaximo,
        activo: activo,
      );

      if (response.success && response.data != null) {
        _products.insert(0, response.data!);
        _errorMessage = null;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> updateProduct(
    int id, {
    String? nombre,
    String? codigo,
    String? descripcion,
    int? categoriaId,
    int? marcaId,
    int? proveedorId,
    int? unidadMedidaId,
    double? precioCompra,
    double? precioVenta,
    int? stockMinimo,
    int? stockMaximo,
    bool? activo,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _productService.updateProduct(
        id,
        nombre: nombre,
        codigo: codigo,
        descripcion: descripcion,
        categoriaId: categoriaId,
        marcaId: marcaId,
        proveedorId: proveedorId,
        unidadMedidaId: unidadMedidaId,
        precioCompra: precioCompra,
        precioVenta: precioVenta,
        stockMinimo: stockMinimo,
        stockMaximo: stockMaximo,
        activo: activo,
      );

      if (response.success && response.data != null) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = response.data!;
        }
        _errorMessage = null;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;

    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _productService.deleteProduct(id);

      if (response.success) {
        _products.removeWhere((p) => p.id == id);
        _errorMessage = null;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        _errorMessage = response.message;
        // Retrasar notifyListeners hasta después del build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    } finally {
      _isLoading = false;
      // Retrasar notifyListeners hasta después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void clearError() {
    _errorMessage = null;
    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearProducts() {
    _products = [];
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _hasMorePages = true;
    _errorMessage = null;
    // Retrasar notifyListeners hasta después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
