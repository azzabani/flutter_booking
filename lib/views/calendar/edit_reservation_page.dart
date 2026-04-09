// lib/views/calendar/edit_reservation_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_booking/models/reservation_model.dart';
import 'package:flutter_booking/services/notification_service.dart';
import 'package:flutter_booking/services/auth_service.dart';

class EditReservationPage extends StatefulWidget {
  final ReservationModel reservation;
  const EditReservationPage({super.key, required this.reservation});

  @override
  State<EditReservationPage> createState() => _EditReservationPageState();
}

class _EditReservationPageState extends State<EditReservationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notifService = NotificationService();
  final AuthService _authService = AuthService();

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  late TextEditingController _notesController;

  bool _isLoading = false;
  Map<DateTime, List<dynamic>> _bookedSlots = {};
  String _resourceName = 'Ressource';

  final List<TimeOfDay> _timeSlots = [
    for (int h = 8; h <= 17; h++) TimeOfDay(hour: h, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.reservation.startTime;
    _focusedDay = widget.reservation.startTime;
    _selectedStartTime = TimeOfDay.fromDateTime(widget.reservation.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(widget.reservation.endTime);
    _notesController =
        TextEditingController(text: widget.reservation.notes ?? '');
    _loadBookedSlots();
    _loadResourceName();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadResourceName() async {
    final doc = await _firestore
        .collection('resources')
        .doc(widget.reservation.resourceId)
        .get();
    if (doc.exists && mounted) {
      setState(() => _resourceName = doc.data()?['name'] ?? 'Ressource');
    }
  }

  Future<void> _loadBookedSlots() async {
    final snap = await _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: widget.reservation.resourceId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    final Map<DateTime, List<dynamic>> slots = {};
    for (final doc in snap.docs) {
      // Exclure la réservation actuelle
      if (doc.id == widget.reservation.id) continue;
      final d = doc.data();
      final start = (d['startTime'] as Timestamp).toDate();
      final key = DateTime(start.year, start.month, start.day);
      slots.putIfAbsent(key, () => []).add({
        'start': start,
        'end': (d['endTime'] as Timestamp).toDate(),
      });
    }
    if (mounted) setState(() => _bookedSlots = slots);
  }

  bool _isSlotAvailable(DateTime date, TimeOfDay time) {
    final key = DateTime(date.year, date.month, date.day);
    if (!_bookedSlots.containsKey(key)) return true;
    final slotStart =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final slotEnd = slotStart.add(const Duration(hours: 1));
    for (final b in _bookedSlots[key]!) {
      if (slotStart.isBefore(b['end']) && slotEnd.isAfter(b['start'])) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveChanges() async {
    if (_selectedStartTime == null || _selectedEndTime == null) {
      _showSnack('Veuillez sélectionner les créneaux horaires', isError: true);
      return;
    }

    final startDT = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, _selectedStartTime!.hour, _selectedStartTime!.minute);
    final endDT = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, _selectedEndTime!.hour, _selectedEndTime!.minute);

    if (!endDT.isAfter(startDT)) {
      _showSnack("L'heure de fin doit être après l'heure de début",
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore
          .collection('reservations')
          .doc(widget.reservation.id)
          .update({
        'startTime': Timestamp.fromDate(startDT),
        'endTime': Timestamp.fromDate(endDT),
        'notes': _notesController.text.trim(),
        'status': 'pending', // remet en attente si modifiée
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notification de modification
      final user = _authService.currentUser;
      if (user != null) {
        await _notifService.createNotification(
        userId: user.uid,
        title: '📝 Réservation modifiée',
        message:
            '$_resourceName – ${DateFormat('dd/MM/yyyy à HH:mm').format(startDT)}',
        type: 'modification',
        reservationId: widget.reservation.id, // ✅ AJOUT ICI
      );
      }

      if (mounted) {
        _showSnack('Réservation modifiée avec succès');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Erreur : $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la réservation'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info ressource
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_resourceName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Modification remet la réservation en attente',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Choisir la date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TableCalendar(
                locale: 'fr_FR',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _selectedStartTime = null;
                    _selectedEndTime = null;
                  });
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF93C5FD),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Créneau de début',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((t) {
                final available = _isSlotAvailable(_selectedDay, t);
                final isSelected = _selectedStartTime == t;
                return GestureDetector(
                  onTap: available
                      ? () => setState(() {
                            _selectedStartTime = t;
                            _selectedEndTime = null;
                          })
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : available
                              ? Colors.white
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : available
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      t.format(context),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : available
                                ? Colors.black87
                                : Colors.grey.shade400,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedStartTime != null) ...[
              const SizedBox(height: 20),
              const Text('Créneau de fin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots
                    .where((t) =>
                        t.hour > _selectedStartTime!.hour ||
                        (t.hour == _selectedStartTime!.hour &&
                            t.minute > _selectedStartTime!.minute))
                    .map((t) {
                  final available = _isSlotAvailable(_selectedDay, t);
                  final isSelected = _selectedEndTime == t;
                  return GestureDetector(
                    onTap: available
                        ? () => setState(() => _selectedEndTime = t)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : available
                                ? Colors.white
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : available
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        t.format(context),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : available
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Raison, commentaire…',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enregistrer les modifications',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
