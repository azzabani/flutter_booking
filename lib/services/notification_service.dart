// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une notification pour un utilisateur
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // 'reservation', 'validation', 'cancellation'
    required String reservationId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'reservationId': reservationId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Notification créée pour: $userId');
    } catch (e) {
      print('❌ Erreur notification: $e');
    }
  }

  // Récupérer les notifications non lues d'un utilisateur
  Stream<List<QueryDocumentSnapshot>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Compter les notifications non lues
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}