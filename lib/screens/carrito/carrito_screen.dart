import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          Consumer<CarritoProvider>(
            builder: (context, carritoProvider, _) {
              if (carritoProvider.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Vaciar carrito',
                onPressed: () => _mostrarDialogoVaciarCarrito(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<CarritoProvider>(
        builder: (context, carritoProvider, _) {
          if (carritoProvider.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Lista de items del carrito
              Expanded(
                child: ListView.builder(
                  itemCount: carritoProvider.items.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final item = carritoProvider.items[index];
                    return _CarritoItemCard(
                      item: item,
                      onIncrement: () {
                        carritoProvider.incrementarCantidad(item.producto.id);
                      },
                      onDecrement: () {
                        carritoProvider.decrementarCantidad(item.producto.id);
                      },
                      onRemove: () {
                        carritoProvider.eliminarProducto(item.producto.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.producto.nombre} eliminado del carrito'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onUpdateCantidad: (nuevaCantidad) {
                        carritoProvider.actualizarCantidad(
                          item.producto.id,
                          nuevaCantidad,
                        );
                      },
                    );
                  },
                ),
              ),

              // Resumen de totales
              _buildResumenTotales(context, carritoProvider),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CarritoProvider>(
        builder: (context, carritoProvider, _) {
          if (carritoProvider.isEmpty) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _continuarCompra(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Continuar Compra',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega productos para continuar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Ver Productos'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenTotales(BuildContext context, CarritoProvider carritoProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilaTotales(
            'Subtotal',
            carritoProvider.subtotal,
            Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          _buildFilaTotales(
            'Impuesto (13%)',
            carritoProvider.impuesto,
            Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 24),
          _buildFilaTotales(
            'Total',
            carritoProvider.total,
            Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaTotales(String label, double valor, TextStyle? style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          'Bs ${valor.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }

  void _mostrarDialogoVaciarCarrito(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Vaciar Carrito'),
          content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<CarritoProvider>().limpiarCarrito();
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carrito vaciado'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Vaciar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _continuarCompra(BuildContext context) {
    // Verificar que el carrito no esté vacío
    final carritoProvider = context.read<CarritoProvider>();

    if (carritoProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navegar a selección de dirección de entrega
    Navigator.pushNamed(context, '/direccion-entrega-seleccion');
  }
}

class _CarritoItemCard extends StatelessWidget {
  final CarritoItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final Function(double) onUpdateCantidad;

  const _CarritoItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onUpdateCantidad,
  });

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    producto.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Código del producto
                  Text(
                    'Código: ${producto.codigo}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Precio unitario
                  Text(
                    'Bs ${item.precioUnitario.toStringAsFixed(2)} c/u',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),

                  // Controles de cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botones de cantidad
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: onDecrement,
                              icon: const Icon(Icons.remove, size: 18),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                item.cantidad.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onIncrement,
                              icon: const Icon(Icons.add, size: 18),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtotal del item
                      Text(
                        'Bs ${item.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón eliminar
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }
}
