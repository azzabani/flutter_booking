// lib/views/admin/admin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_booking/views/admin/admin_dashboard_page.dart';
import 'package:flutter_booking/views/admin/admin_resource_page.dart';
import 'package:flutter_booking/views/admin/admin_validate_page.dart';
import 'package:flutter_booking/views/admin/admin_reservations_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: const Color(0xFF1D4ED8),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Ressources'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Validation'),
            Tab(icon: Icon(Icons.list_alt), text: 'Toutes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminDashboardPage(),
          AdminResourcePage(),
          AdminValidatePage(),
          AdminReservationsPage(),
        ],
      ),
    );
  }
}
