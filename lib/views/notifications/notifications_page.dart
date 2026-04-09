// lib/views/notifications/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking/services/auth_service.dart';
import 'package:flutter_booking/services/notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final notifService = NotificationService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // ✅ Tout marquer comme lu
          TextButton.icon(
            onPressed: () async {
              final snap = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .where('isRead', isEqualTo: false)
                  .get();

              for (final doc in snap.docs) {
                await notifService.markAsRead(doc.id);
              }
            },
            icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
            label: const Text('Tout lire',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: notifService.getUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final isRead = data['isRead'] ?? false;
              final type = data['type'] ?? 'reservation';
              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final reservationId = data['reservationId']; // ✅ récupéré

              final createdAt = data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now();

              return InkWell(
                onTap: () async {
                  await notifService.markAsRead(doc.id);

                  // ✅ Navigation (optionnel)
                  if (reservationId != null) {
                    Navigator.pushNamed(
                      context,
                      '/reservation_details',
                      arguments: reservationId,
                    );
                  }
                },
                child: Container(
                  color: isRead ? null : Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icône
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _typeColor(type).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _typeIcon(type),
                          color: _typeColor(type),
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),

                                // ✅ Supprimer notification
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('notifications')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🎨 Couleurs
  Color _typeColor(String type) {
    switch (type) {
      case 'validation':
        return Colors.green;
      case 'cancellation':
        return Colors.red;
      case 'modification':
        return Colors.orange; // ✅ ajouté
      default:
        return Colors.blue;
    }
  }

  // 🔔 Icônes
  IconData _typeIcon(String type) {
    switch (type) {
      case 'validation':
        return Icons.check_circle_outline;
      case 'cancellation':
        return Icons.cancel_outlined;
      case 'modification':
        return Icons.edit_calendar; // ✅ ajouté
      default:
        return Icons.event_note;
    }
  }

  // ⏱️ Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';

    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
  }
}