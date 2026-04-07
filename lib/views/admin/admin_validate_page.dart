// lib/views/admin/admin_validate_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking/services/notification_service.dart';

class AdminValidatePage extends StatefulWidget {
  const AdminValidatePage({super.key});

  @override
  State<AdminValidatePage> createState() => _AdminValidatePageState();
}

class _AdminValidatePageState extends State<AdminValidatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  String _selectedTab = 'pending';
  bool _isProcessing = false;

  Future<void> _updateStatus(String id, String status) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Récupérer les informations de la réservation
      final reservationDoc = await _firestore.collection('reservations').doc(id).get();
      final reservationData = reservationDoc.data()!;
      final userId = reservationData['userId'];
      final resourceId = reservationData['resourceId'];
      final userName = reservationData['userName'] ?? 'Utilisateur';
      
      // Récupérer le nom de la ressource
      final resourceDoc = await _firestore.collection('resources').doc(resourceId).get();
      final resourceName = resourceDoc.data()?['name'] ?? 'Ressource';
      
      // Récupérer la date de réservation
      final startTime = (reservationData['startTime'] as Timestamp).toDate();
      final formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(startTime);
      
      // Mettre à jour le statut
      await _firestore.collection('reservations').doc(id).update({
        'status': status,
        'validatedAt': FieldValue.serverTimestamp(),
      });
      
      // 🔔 Notification pour l'utilisateur
      await _notificationService.createNotification(
        userId: userId,
        title: status == 'confirmed' ? '✅ Réservation confirmée' : '❌ Réservation rejetée',
        message: status == 'confirmed'
            ? 'Votre réservation pour "$resourceName" le $formattedDate a été confirmée.'
            : 'Votre réservation pour "$resourceName" le $formattedDate a été rejetée.',
        type: status == 'confirmed' ? 'confirmation' : 'rejection',
        reservationId: id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'confirmed' ? '✅ Réservation confirmée' : '❌ Réservation rejetée'),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
              stream: _firestore.collection('reservations').snapshots(),  // ← Pas de where, pas de orderBy
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text('Erreur: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Filtrage manuel selon l'onglet sélectionné
                var docs = snapshot.data!.docs;
                
                if (_selectedTab == 'pending') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'pending';
                  }).toList();
                } else if (_selectedTab == 'confirmed') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'confirmed';
                  }).toList();
                }
                
                // Tri manuel par date décroissante
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bDate = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return bDate.compareTo(aDate);
                });
                
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 'pending' 
                              ? 'Aucune réservation en attente'
                              : _selectedTab == 'confirmed'
                                  ? 'Aucune réservation confirmée'
                                  : 'Aucune réservation',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
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
    final isSelected = _selectedTab == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTab = value;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCard(String id, Map<String, dynamic> data) {
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final status = data['status'] ?? 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec utilisateur
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('resources')
                            .doc(data['resourceId'])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final resourceData = snapshot.data!.data() as Map<String, dynamic>;
                            return Text(
                              resourceData['name'] ?? 'Ressource',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
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
            
            // Date et heure
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(startTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            
            // Notes
            if (data['notes'] != null && data['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '📝 ${data['notes']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            
            // Date de création
            if (data['createdAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Créée le ${DateFormat('dd/MM/yyyy HH:mm').format((data['createdAt'] as Timestamp).toDate())}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            
            // Boutons d'action
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _updateStatus(id, 'confirmed'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _updateStatus(id, 'rejected'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rejeter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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