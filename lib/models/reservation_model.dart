// lib/models/reservation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String resourceId;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending, confirmed, cancelled, rejected
  final String? notes;
  final DateTime createdAt;
  final DateTime? validatedAt;
  final String? validatedBy;

  ReservationModel({
    required this.id,
    required this.resourceId,
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

  // Getter pour vérifier si la réservation est active
  bool get isActive => status == 'pending' || status == 'confirmed';

  // Convertir depuis Firestore
  factory ReservationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReservationModel(
      id: id,
      resourceId: data['resourceId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      validatedAt: data['validatedAt'] != null 
          ? (data['validatedAt'] as Timestamp).toDate() 
          : null,
      validatedBy: data['validatedBy'],
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'resourceId': resourceId,
      'userId': userId,
      'userName': userName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (validatedAt != null) 'validatedAt': Timestamp.fromDate(validatedAt!),
      if (validatedBy != null) 'validatedBy': validatedBy,
    };
  }

  // Copie avec modifications
  ReservationModel copyWith({
    String? id,
    String? resourceId,
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
}