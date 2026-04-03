// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String? _userName;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
     }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'];
          _userRole = userData['role'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec bienvenue
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _userName ?? 'Utilisateur',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRoleText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getRoleColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.event_seat,
                            size: 30,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Menu principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Section des ressources
                      _buildMenuCard(
                        context,
                        title: 'Ressources disponibles',
                        subtitle: 'Consulter et réserver',
                        icon: Icons.inventory_2_outlined,
                        color: Colors.blue,
                        onTap: () {
                          // Naviguer vers la liste des ressources
                          Navigator.pushNamed(context, '/resources');
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Section calendrier
                      _buildMenuCard(
                        context,
                        title: 'Mon calendrier',
                        subtitle: 'Voir mes réservations',
                        icon: Icons.calendar_today,
                        color: Colors.green,
                        onTap: () {
                          // Naviguer vers le calendrier
                          Navigator.pushNamed(context, '/calendar');
                          },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Section admin (visible seulement pour admin/manager)
                      if (_userRole == 'admin' || _userRole == 'manager')
                        _buildMenuCard(
                          context,
                          title: 'Administration',
                          subtitle: 'Gérer les ressources et utilisateurs',
                          icon: Icons.admin_panel_settings,
                          color: Colors.orange,
                          onTap: () {
                            // Naviguer vers l'admin
                            Navigator.pushNamed(context, '/admin');
                          },
                        ),
                        const Spacer(),
                      
                      // Bouton déconnexion
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Se déconnecter'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.red.shade300),
                            foregroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
     }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (_userRole) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getRoleText() {
    switch (_userRole) {
       case 'admin':
        return 'Administrateur';
      case 'manager':
        return 'Manager';
      default:
        return 'Utilisateur';
    }
  }
}