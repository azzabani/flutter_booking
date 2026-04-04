// lib/views/admin/admin_validate_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminValidatePage extends StatefulWidget {
  const AdminValidatePage({super.key});

  @override
  State<AdminValidatePage> createState() => _AdminValidatePageState();
}

class _AdminValidatePageState extends State<AdminValidatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedTab = 'pending';

  Future<void> _updateStatus(String id, String status) async {
    await _firestore.collection('reservations').doc(id).update({
      'status': status,
      'validatedAt': FieldValue.serverTimestamp(),
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == 'confirmed' ? '✅ Réservation confirmée' : '❌ Réservation rejetée'),
        backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des réservations'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('En attente', 'pending', Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTab('Confirmées', 'confirmed', Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTab('Toutes', 'all', Colors.blue),
                ),
              ],
            ),
          ),
          
          // Liste
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 'pending' 
                              ? 'Aucune réservation en attente'
                              : 'Aucune réservation',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, Color color) {
    return FilterChip(
      label: Text(label),
      selected: _selectedTab == value,
      onSelected: (selected) {
        setState(() {
          _selectedTab = value;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: _selectedTab == value ? color : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Stream<QuerySnapshot> _getStream() {
    if (_selectedTab == 'pending') {
      return _firestore
          .collection('reservations')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else if (_selectedTab == 'confirmed') {
      return _firestore
          .collection('reservations')
          .where('status', isEqualTo: 'confirmed')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Widget _buildCard(String id, Map<String, dynamic> data) {
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final status = data['status'] ?? 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: status == 'pending' ? Colors.orange : Colors.green,
                  radius: 16,
                  child: Text(
                    status == 'pending' ? '⏳' : '✅',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      FutureBuilder(
                        future: _firestore.collection('resources').doc(data['resourceId']).get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            return Text(
                              snapshot.data!['name'] ?? 'Ressource',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(DateFormat('dd/MM/yyyy').format(startTime)),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}'),
              ],
            ),
            if (data['notes'] != null && data['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '📝 ${data['notes']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(id, 'confirmed'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(id, 'rejected'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rejeter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}