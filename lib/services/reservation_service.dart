// lib/services/reservation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/resource_model.dart';
import 'package:flutter_booking/models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer toutes les ressources
  Stream<List<ResourceModel>> getResources() {
    return _firestore
        .collection('resources')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResourceModel(
                  id: doc.id,
                  name: doc.data()['name'] ?? '',
                  description: doc.data()['description'] ?? '',
                  image: doc.data()['image'] ?? '',
                  capacity: doc.data()['capacity'] ?? 0,
                  category: doc.data()['category'] ?? 'autre',
                ))
            .toList());
  }

  // Récupérer les ressources par catégorie
  Stream<List<ResourceModel>> getResourcesByCategory(String category) {
    return _firestore
        .collection('resources')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResourceModel(
                  id: doc.id,
                  name: doc.data()['name'] ?? '',
                  description: doc.data()['description'] ?? '',
                  image: doc.data()['image'] ?? '',
                  capacity: doc.data()['capacity'] ?? 0,
                  category: doc.data()['category'] ?? 'autre',
                ))
            .toList());
  }

  // Créer une réservation
  Future<bool> createReservation({
    required String resourceId,
    required String userId,
    required String userName,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      // Vérifier les conflits
      bool hasConflict = await checkConflict(resourceId, startTime, endTime);

      if (hasConflict) {
        return false;
      }

      // Créer la réservation
      await _firestore.collection('reservations').add({
        'resourceId': resourceId,
        'userId': userId,
        'userName': userName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'pending',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur création réservation: $e');
      return false;
    }
  }

  // Vérifier les conflits
  Future<bool> checkConflict(
    String resourceId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    QuerySnapshot conflicts = await _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: resourceId)
        .where('status', isNotEqualTo: 'cancelled')
        .where('status', isNotEqualTo: 'rejected')
        .get();

    for (var doc in conflicts.docs) {
      DateTime existingStart = (doc['startTime'] as Timestamp).toDate();
      DateTime existingEnd = (doc['endTime'] as Timestamp).toDate();
      
      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        return true;
      }
    }
    
    return false;
  }

  // Récupérer les réservations d'un utilisateur
  Stream<List<Reservation>> getUserReservations(String userId) {
    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation(
                  id: doc.id,
                  resourceId: doc['resourceId'],
                  userId: doc['userId'],
                  userName: doc['userName'],
                  startTime: (doc['startTime'] as Timestamp).toDate(),
                  endTime: (doc['endTime'] as Timestamp).toDate(),
                  status: doc['status'],
                  notes: doc['notes'],
                  createdAt: (doc['createdAt'] as Timestamp).toDate(),
                ))
            .toList());
  }

  // Annuler une réservation
  Future<void> cancelReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}