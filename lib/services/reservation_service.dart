// lib/services/reservation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/resource_model.dart';
import 'package:flutter_booking/models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Ressources ───────────────────────────────────────────────────────────

  Stream<List<ResourceModel>> getResources() {
    return _firestore.collection('resources').snapshots().map(
          (snapshot) => snapshot.docs.map(_docToResource).toList(),
        );
  }

  Stream<List<ResourceModel>> getResourcesByCategory(String category) {
    return _firestore
        .collection('resources')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_docToResource).toList());
  }

  ResourceModel _docToResource(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      capacity: data['capacity'] ?? 0,
      category: data['category'] ?? 'autre',
    );
  }

  // ─── Créer une réservation ────────────────────────────────────────────────

  Future<bool> createReservation({
    required String resourceId,
    required String userId,
    required String userName,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final hasConflict = await checkConflict(resourceId, startTime, endTime);
      if (hasConflict) return false;

      await _firestore.collection('reservations').add({
        'resourceId': resourceId,
        'userId': userId,
        'userName': userName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'pending',
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur création réservation: $e');
      return false;
    }
  }

  // ─── Vérifier les conflits ────────────────────────────────────────────────
  //
  // FIX BUG 1 : Firestore n'autorise pas deux clauses `isNotEqualTo` sur le
  // même champ dans une seule requête. On filtre côté client à la place.

  Future<bool> checkConflict(
    String resourceId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // On récupère toutes les réservations de cette ressource…
    final snapshot = await _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: resourceId)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';

      // …et on exclut manuellement les annulées / rejetées
      if (status == 'cancelled' || status == 'rejected') continue;

      final existingStart = (data['startTime'] as Timestamp).toDate();
      final existingEnd = (data['endTime'] as Timestamp).toDate();

      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        return true; // conflit détecté
      }
    }

    return false;
  }

  // ─── Réservations d'un utilisateur ───────────────────────────────────────
  //
  // FIX BUG 2 : `.where('userId').orderBy('startTime')` exige un index
  // composite Firestore. On récupère sans orderBy et on trie côté client.
  // FIX BUG 3 : `createdAt` peut être null juste après l'écriture
  // (FieldValue.serverTimestamp() est résolu de façon asynchrone).

  Stream<List<Reservation>> getUserReservations(String userId) {
    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        // Pas de orderBy ici → pas d'index composite requis
        .snapshots()
        .map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => _docToReservation(doc))
          .whereType<Reservation>() // filtre les null (docs corrompus)
          .toList();

      // Tri côté client : plus récent en premier
      reservations.sort((a, b) => b.startTime.compareTo(a.startTime));
      return reservations;
    });
  }

  // ─── Toutes les réservations (admin) ─────────────────────────────────────

  Stream<List<Reservation>> getAllReservations({String? statusFilter}) {
    // Pas de orderBy → pas d'index requis. Tri côté client.
    Query query = _firestore.collection('reservations');

    if (statusFilter != null && statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots().map((snapshot) {
      final reservations = snapshot.docs
          .map((doc) => _docToReservation(doc))
          .whereType<Reservation>()
          .toList();

      reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reservations;
    });
  }

  // ─── Réservations d'une ressource (vue calendrier) ───────────────────────

  Stream<List<Reservation>> getResourceReservations(String resourceId) {
    return _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: resourceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _docToReservation(doc))
          .whereType<Reservation>()
          .toList();
    });
  }

  // ─── Annuler une réservation ──────────────────────────────────────────────

  Future<void> cancelReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Helper : convertir un doc Firestore en Reservation ──────────────────
  //
  // FIX BUG 3 : createdAt peut être null (serverTimestamp pas encore résolu).
  // On retourne null si le doc est invalide (resourceId ou userId vide).

  Reservation? _docToReservation(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // FIX BUG 4 : resourceId vide → crash "document path must be non-empty"
      final resourceId = (data['resourceId'] as String? ?? '').trim();
      final userId = (data['userId'] as String? ?? '').trim();
      if (resourceId.isEmpty || userId.isEmpty) return null;

      // createdAt peut être null tant que serverTimestamp n'est pas résolu
      DateTime createdAt;
      if (data['createdAt'] != null) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.now(); // valeur de secours
      }

      return Reservation(
        id: doc.id,
        resourceId: resourceId,
        userId: userId,
        userName: data['userName'] ?? 'Utilisateur',
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
        status: data['status'] ?? 'pending',
        notes: data['notes'] as String?,
        createdAt: createdAt,
      );
    } catch (e) {
      print('⚠️ Doc ${doc.id} ignoré (données invalides) : $e');
      return null;
    }
  }
}
