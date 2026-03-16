// lib/models/reservation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String resourceId;
  final String resourceName; // dénormalisé pour affichage rapide
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending | confirmed | cancelled | rejected
  final String? notes;
  final DateTime createdAt;
  final DateTime? validatedAt;
  final String? validatedBy; // nom du manager/admin qui a validé

  const ReservationModel({
    required this.id,
    required this.resourceId,
    this.resourceName = '',
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.validatedAt,
    this.validatedBy,
  });

  factory ReservationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    DateTime parseTs(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return ReservationModel(
      id: id,
      resourceId: (data['resourceId'] as String? ?? '').trim(),
      resourceName: data['resourceName'] as String? ?? '',
      userId: (data['userId'] as String? ?? '').trim(),
      userName: data['userName'] as String? ?? 'Utilisateur',
      startTime: parseTs(data['startTime']),
      endTime: parseTs(data['endTime']),
      status: data['status'] as String? ?? 'pending',
      notes: data['notes'] as String?,
      createdAt: parseTs(data['createdAt']),
      validatedAt:
          data['validatedAt'] != null ? parseTs(data['validatedAt']) : null,
      validatedBy: data['validatedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'resourceId': resourceId,
      'resourceName': resourceName,
      'userId': userId,
      'userName': userName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'notes': notes ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      if (validatedAt != null)
        'validatedAt': Timestamp.fromDate(validatedAt!),
      if (validatedBy != null) 'validatedBy': validatedBy,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? resourceId,
    String? resourceName,
    String? userId,
    String? userName,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? validatedAt,
    String? validatedBy,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';
  bool get isActive => status == 'confirmed' || status == 'pending';

  @override
  String toString() =>
      'ReservationModel(id: $id, resource: $resourceId, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
