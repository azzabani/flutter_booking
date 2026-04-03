// lib/models/reservation.dart
class Reservation {
  final String id;
  final String resourceId;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'rejected'
  final String? notes;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.resourceId,
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  // Convertir depuis Firestore
  factory Reservation.fromFirestore(Map<String, dynamic> data, String id) {
    return Reservation(
      id: id,
      resourceId: data['resourceId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      startTime: (data['startTime'] as dynamic).toDate(),
      endTime: (data['endTime'] as dynamic).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'resourceId': resourceId,
      'userId': userId,
      'userName': userName,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}