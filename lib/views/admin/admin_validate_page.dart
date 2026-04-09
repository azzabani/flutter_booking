// lib/views/admin/admin_validate_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking/models/reservation_model.dart';
import 'package:flutter_booking/services/reservation_service.dart';
import 'package:flutter_booking/services/notification_service.dart';

class AdminValidatePage extends StatefulWidget {
  const AdminValidatePage({super.key});

  @override
  State<AdminValidatePage> createState() => _AdminValidatePageState();
}

class _AdminValidatePageState extends State<AdminValidatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReservationService _reservationService = ReservationService();
  final NotificationService _notificationService = NotificationService();

  String _selectedTab = 'pending';
  bool _isProcessing = false;

  // ─── Mise à jour du statut ─────────────────────────────────────────────────

  Future<void> _updateStatus(ReservationModel reservation, String status) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final resourceId = reservation.resourceId;

      // Nom de la ressource
      String resourceName = 'Ressource';
      if (resourceId.isNotEmpty) {
        final resourceDoc =
            await _firestore.collection('resources').doc(resourceId).get();
        if (resourceDoc.exists) {
          resourceName =
              (resourceDoc.data() as Map<String, dynamic>)['name'] ?? 'Ressource';
        }
      }

      final formattedDate =
          DateFormat('dd/MM/yyyy à HH:mm').format(reservation.startTime);

      // Mise à jour Firestore
      await _firestore
          .collection('reservations')
          .doc(reservation.id)
          .update({
        'status': status,
        'validatedAt': FieldValue.serverTimestamp(),
      });

      // Notification in-app
      await _notificationService.createNotification(
        userId: reservation.userId,
        title: status == 'confirmed'
            ? '✅ Réservation confirmée'
            : '❌ Réservation rejetée',
        message: status == 'confirmed'
            ? 'Votre réservation pour "$resourceName" le $formattedDate a été confirmée.'
            : 'Votre réservation pour "$resourceName" le $formattedDate a été rejetée.',
        type: status == 'confirmed' ? 'confirmation' : 'rejection',
        reservationId: reservation.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'confirmed'
                ? '✅ Réservation confirmée'
                : '❌ Réservation rejetée'),
            backgroundColor:
                status == 'confirmed' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
          _buildTabBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ─── Onglets ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
              child: _buildTab('En attente', 'pending', Colors.orange)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildTab('Confirmées', 'confirmed', Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _buildTab('Toutes', 'all', Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, Color color) {
    final isSelected = _selectedTab == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTab = value),
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ─── Liste ─────────────────────────────────────────────────────────────────

  Widget _buildList() {
    final statusFilter =
        _selectedTab == 'all' ? null : _selectedTab;

    return StreamBuilder<List<ReservationModel>>(
      stream: _reservationService.getAllReservations(statusFilter: statusFilter),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reservations = snapshot.data ?? [];

        if (reservations.isEmpty) {
          return _buildEmpty();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) =>
              _buildCard(reservations[index]),
        );
      },
    );
  }

  // ─── États vides / erreur ──────────────────────────────────────────────────

  Widget _buildEmpty() {
    final messages = {
      'pending': 'Aucune réservation en attente',
      'confirmed': 'Aucune réservation confirmée',
      'all': 'Aucune réservation',
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            messages[_selectedTab] ?? 'Aucune réservation',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte réservation ─────────────────────────────────────────────────────

  Widget _buildCard(ReservationModel reservation) {
    final status = reservation.status;
    final statusColor = _statusColor(status);
    final statusEmoji = _statusEmoji(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.15),
                  radius: 18,
                  child: Text(statusEmoji, style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      // Nom de la ressource via FutureBuilder sécurisé
                      _buildResourceName(reservation.resourceId),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Date & heure
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(reservation.startTime),
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(reservation.startTime)} - '
                  '${DateFormat('HH:mm').format(reservation.endTime)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),

            // Notes
            if (reservation.notes != null &&
                reservation.notes!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reservation.notes!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),

            // Date création
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Créée le ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.createdAt)}',
                style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),

            // Boutons confirmer / rejeter (uniquement si pending)
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus(reservation, 'confirmed'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus(reservation, 'rejected'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Rejeter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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

  // ─── Nom de la ressource (sécurisé) ───────────────────────────────────────

  Widget _buildResourceName(String resourceId) {
    if (resourceId.isEmpty) {
      return Text('Ressource inconnue',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('resources').doc(resourceId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Chargement…',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade400));
        }
        if (!snapshot.data!.exists) {
          return Text('Ressource supprimée',
              style:
                  TextStyle(fontSize: 12, color: Colors.orange.shade400));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          data['name'] ?? 'Ressource',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        );
      },
    );
  }

  // ─── Helpers statut ───────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusEmoji(String status) {
    switch (status) {
      case 'confirmed':
        return '✅';
      case 'rejected':
        return '❌';
      case 'cancelled':
        return '🚫';
      default:
        return '⏳';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'rejected':
        return 'Rejetée';
      case 'cancelled':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }
}