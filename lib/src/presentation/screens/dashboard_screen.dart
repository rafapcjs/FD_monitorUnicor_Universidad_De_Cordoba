import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'users_management_screen.dart';
import 'plants_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String accessToken;

  const DashboardScreen({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Panel de Control IoT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implementar notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Implementar configuración
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del usuario
            ThemedCard(
              gradient: AppTheme.surfaceGradient,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.dashboard_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel de Control',
                          style: context.textTheme.displaySmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gestiona tu sistema IoT desde aquí',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Grid de funcionalidades
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildModernCard(
                    context,
                    'Gestión de Usuarios',
                    'Administra permisos y accesos',
                    Icons.people_outline,
                    AppTheme.primaryGradient,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersManagementScreen(
                            accessToken: accessToken,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildModernCard(
                    context,
                    'Gestión de Plantas',
                    'Administra tu inventario de plantas',
                    Icons.local_florist,
                    const LinearGradient(
                      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantsManagementScreen(
                            accessToken: accessToken,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildModernCard(
                    context,
                    'Sensores IoT',
                    'Configurar y monitorear sensores',
                    Icons.sensors,
                    AppTheme.accentGradient,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Función próximamente disponible'),
                            ],
                          ),
                          backgroundColor: AppTheme.info,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildModernCard(
                    context,
                    'Reportes',
                    'Analiza datos y tendencias',
                    Icons.analytics_outlined,
                    const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Sistema de reportes en desarrollo'),
                            ],
                          ),
                          backgroundColor: AppTheme.info,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método moderno para crear cards
  Widget _buildModernCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return ThemedCard(
      gradient: gradient,
      onTap: onTap,
      shadow: AppTheme.mediumShadow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 10,
            ),
          ),
        ],
      ),
    );
  }
}
