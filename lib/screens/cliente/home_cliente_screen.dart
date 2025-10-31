import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../screens.dart';

/// Pantalla principal para usuarios con rol CLIENTE
///
/// Muestra:
/// - Dashboard con acceso rápido
/// - Productos destacados
/// - Mis pedidos recientes
/// - Estado de envíos activos
class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const ProductListScreen(),
    const PedidosHistorialScreen(),
    const _PerfilTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  Future<void> _cargarDatosIniciales() async {
    if (!mounted) return;

    try {
      final pedidoProvider = context.read<PedidoProvider>();
      final productProvider = context.read<ProductProvider>();

      // Cargar pedidos recientes (solo primeros 5)
      await pedidoProvider.loadPedidos();

      // Cargar productos
      if (mounted) {
        await productProvider.loadProducts();
      }
    } catch (e) {
      debugPrint('❌ Error cargando datos iniciales: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuidora Paucara'),
        actions: [
          // Carrito
          IconButton(
            icon: const Badge(
              label: Text('0'), // TODO: Actualizar con cantidad real
              child: Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/carrito');
            },
          ),
          // Notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Abrir notificaciones
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Mis Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Tab de Dashboard (Inicio)
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pedidoProvider = context.watch<PedidoProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await pedidoProvider.loadPedidos(refresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            _buildWelcomeBanner(context, authProvider.user?.name ?? 'Cliente'),

            const SizedBox(height: 24),

            // Acciones rápidas
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // Pedidos recientes
            _buildRecentOrders(context, pedidoProvider),

            const SizedBox(height: 24),

            // Envíos activos
            _buildActiveShipments(context, pedidoProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String userName) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $userName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bienvenido a tu tienda de distribución',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.inventory_2,
                title: 'Ver Productos',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/products');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.shopping_cart,
                title: 'Mi Carrito',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/carrito');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long,
                title: 'Mis Pedidos',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/mis-pedidos');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.local_shipping,
                title: 'Seguimiento',
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/mis-pedidos');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context, PedidoProvider provider) {
    final pedidosRecientes = provider.pedidos.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pedidos Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mis-pedidos');
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (pedidosRecientes.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes pedidos aún',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pedidosRecientes.length,
            itemBuilder: (context, index) {
              final pedido = pedidosRecientes[index];
              return _OrderCard(pedido: pedido);
            },
          ),
      ],
    );
  }

  Widget _buildActiveShipments(BuildContext context, PedidoProvider provider) {
    final enviosActivos = provider.pedidosEnProceso;

    if (enviosActivos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Envíos Activos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enviosActivos.length,
          itemBuilder: (context, index) {
            final pedido = enviosActivos[index];
            return _ShipmentCard(pedido: pedido);
          },
        ),
      ],
    );
  }
}

/// Tarjeta de acción rápida
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de pedido
class _OrderCard extends StatelessWidget {
  final Pedido pedido;

  const _OrderCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pedido.estadoInfo.color.withValues(alpha: 0.2),
          child: Icon(
            pedido.estadoInfo.icono,
            color: pedido.estadoInfo.color,
          ),
        ),
        title: Text('Pedido ${pedido.numero}'),
        subtitle: Text(
          '${pedido.cantidadItems} items • Bs. ${pedido.total.toStringAsFixed(2)}',
        ),
        trailing: Chip(
          label: Text(
            pedido.estadoInfo.nombre,
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: pedido.estadoInfo.color.withValues(alpha: 0.2),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/pedido-detalle',
            arguments: pedido.id,
          );
        },
      ),
    );
  }
}

/// Tarjeta de envío activo
class _ShipmentCard extends StatelessWidget {
  final Pedido pedido;

  const _ShipmentCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.local_shipping, color: Colors.white),
        ),
        title: Text('Pedido ${pedido.numero}'),
        subtitle: Text(pedido.estadoInfo.nombre),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/pedido-tracking',
              arguments: pedido,
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Seguir'),
        ),
      ),
    );
  }
}

/// Tab de Perfil
class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar y nombre
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'C',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Cliente',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Opciones de perfil
        _buildProfileOption(
          icon: Icons.person,
          title: 'Mi Información',
          onTap: () {
            // TODO: Abrir editar perfil
          },
        ),
        _buildProfileOption(
          icon: Icons.location_on,
          title: 'Mis Direcciones',
          onTap: () {
            // TODO: Abrir direcciones
          },
        ),
        _buildProfileOption(
          icon: Icons.payment,
          title: 'Métodos de Pago',
          onTap: () {
            // TODO: Abrir métodos de pago
          },
        ),
        _buildProfileOption(
          icon: Icons.history,
          title: 'Historial de Pedidos',
          onTap: () {
            Navigator.pushNamed(context, '/mis-pedidos');
          },
        ),
        _buildProfileOption(
          icon: Icons.help_outline,
          title: 'Ayuda',
          onTap: () {
            // TODO: Abrir ayuda
          },
        ),

        const Divider(height: 32),

        // Cerrar sesión
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await context.read<AuthProvider>().logout();
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
