// lib/views/calendar/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/reservation_model.dart';
import 'package:flutter_booking/services/auth_service.dart';
import 'package:flutter_booking/services/reservation_service.dart';
import 'package:flutter_booking/widgets/calendar_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<ReservationModel> _allReservations = [];  // ← Changé ici
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userRole = await _authService.getUserRole();
    _loadReservations();
  }

  void _loadReservations() {
    final user = _authService.currentUser;
    if (user == null) return;

    final stream = _firestore
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    stream.listen((snapshot) {
      final reservations = snapshot.docs.map((doc) {
        final data = doc.data();
        return ReservationModel(
          id: doc.id,
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
      }).toList();

      if (mounted) {
        setState(() {
          _allReservations = reservations;
          _isLoading = false;
        });
      }
    });
  }

  List<ReservationModel> get _selectedDayReservations {
    return _allReservations.where((r) {
      return r.startTime.year == _selectedDay.year &&
          r.startTime.month == _selectedDay.month &&
          r.startTime.day == _selectedDay.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon calendrier'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendrier interactif
                CalendarWidget(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  reservations: _allReservations,  // ← Changé ici
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                ),

                // Titre section du jour
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.event_note, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selectedDayReservations.length} réservation(s)',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Liste des réservations du jour
                Expanded(
                  child: _selectedDayReservations.isEmpty
                      ? _EmptyDayWidget(date: _selectedDay)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: _selectedDayReservations.length,
                          itemBuilder: (context, index) {
                            final res = _selectedDayReservations[index];
                            return _ReservationTile(
                              userName: res.userName,
                              startTime: res.startTime,
                              endTime: res.endTime,
                              status: res.status,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const _ReservationTile({
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _statusText {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fmt.format(startTime)} – ${fmt.format(endTime)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayWidget extends StatelessWidget {
  final DateTime date;
  const _EmptyDayWidget({required this.date});

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isToday ? 'Aucune réservation aujourd\'hui' : 'Aucune réservation ce jour',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}