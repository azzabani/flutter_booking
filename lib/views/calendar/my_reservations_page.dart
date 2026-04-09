// lib/views/calendar/my_reservations_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking/services/auth_service.dart';
import 'package:flutter_booking/services/notification_service.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notifService = NotificationService();

  // ✅ Fonction corrigée avec notification
  Future<void> _cancelReservation(
      String reservationId, String resourceName, DateTime startTime) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'cancelled',
      });

      final user = _authService.currentUser;
      if (user != null) {
        await _notifService.createNotification(
          userId: user.uid,
          title: '❌ Réservation annulée',
          message:
              '$resourceName - ${DateFormat('dd/MM/yyyy à HH:mm').format(startTime)}',
          type: 'cancellation',
          reservationId: reservationId, // ✅ FIX ICI
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reservations')
            .where('userId', isEqualTo: user.uid)
            .orderBy('startTime', descending: true)
            .snapshots(),
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
                  Icon(Icons.calendar_today,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune réservation',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 16),
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

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('resources')
                    .doc(data['resourceId'])
                    .get(),
                builder: (context, resourceSnapshot) {
                  String resourceName = 'Ressource';
                  if (resourceSnapshot.hasData &&
                      resourceSnapshot.data!.exists) {
                    resourceName =
                        resourceSnapshot.data!['name'] ?? 'Ressource';
                  }

                  final startTime =
                      (data['startTime'] as Timestamp).toDate();
                  final endTime =
                      (data['endTime'] as Timestamp).toDate();
                  final status = data['status'] ?? 'pending';

                  Color statusColor;
                  String statusText;

                  switch (status) {
                    case 'confirmed':
                      statusColor = Colors.green;
                      statusText = 'Confirmée';
                      break;
                    case 'pending':
                      statusColor = Colors.orange;
                      statusText = 'En attente';
                      break;
                    case 'cancelled':
                      statusColor = Colors.red;
                      statusText = 'Annulée';
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      statusText = 'Rejetée';
                      break;
                    default:
                      statusColor = Colors.grey;
                      statusText = status;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  resourceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      statusColor.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(startTime),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          if (data['notes'] != null &&
                              data['notes']
                                  .toString()
                                  .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8),
                              child: Text(
                                '📝 ${data['notes']}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ),

                          // ✅ Bouton avec correction
                          if (status == 'pending')
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _cancelReservation(
                                    doc.id,
                                    resourceName,
                                    startTime,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.red.shade300),
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                      'Annuler la réservation'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}