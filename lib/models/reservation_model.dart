// lib/models/reservation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String resourceId;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending' | 'confirmed' | 'cancelled' | 'rejected'
  final String? notes;
  final DateTime createdAt;

  const Reservation({
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

  // ─── Factory depuis Firestore ─────────────────────────────────────────────
  //
  // FIX : tous les champs sont protégés contre null.
  // `createdAt` utilise DateTime.now() si serverTimestamp pas encore résolu.

  factory Reservation.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parseTimestamp(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is Timestamp) return value.toDate();
      return fallback ?? DateTime.now();
    }

    return Reservation(
      id: id,
      resourceId: (data['resourceId'] as String? ?? '').trim(),
      userId: (data['userId'] as String? ?? '').trim(),
      userName: data['userName'] as String? ?? 'Utilisateur',
      startTime: parseTimestamp(data['startTime']),
      endTime: parseTimestamp(data['endTime']),
      status: data['status'] as String? ?? 'pending',
      notes: data['notes'] as String?,
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  // ─── Vers Firestore ───────────────────────────────────────────────────────

  Map<String, dynamic> toFirestore() {
    return {
      'resourceId': resourceId,
      'userId': userId,
      'userName': userName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'notes': notes ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ─── copyWith ─────────────────────────────────────────────────────────────

  Reservation copyWith({
    String? id,
    String? resourceId,
    String? userId,
    String? userName,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';
  bool get isActive => status == 'confirmed' || status == 'pending';

  @override
  String toString() =>
      'Reservation(id: $id, resource: $resourceId, status: $status, '
      'start: $startTime, end: $endTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reservation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
