// lib/views/admin/admin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking/views/admin/admin_resource_page.dart';
import 'package:flutter_booking/views/admin/admin_reservations_page.dart';
import 'package:flutter_booking/services/auth_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthService _authService = AuthService();
  String? _userRole;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getUserRole();
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userRole != 'admin' && _userRole != 'manager') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
          backgroundColor: Colors.red.shade700,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 20),
              const Text(
                'Vous n\'avez pas les droits d\'administration',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // TODO: Ajouter un utilisateur
              },
              tooltip: 'Ajouter un utilisateur',
            ),
        ],
      ),
      body: _selectedIndex == 0
          ? const AdminResourcePage()
          : const AdminReservationsPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservations',
          ),
        ],
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}