// lib/views/calendar/booking_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_booking/models/resource_model.dart';
import 'package:flutter_booking/services/auth_service.dart';

class BookingPage extends StatefulWidget {
  final ResourceModel resource;

  const BookingPage({super.key, required this.resource});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  Map<DateTime, List<dynamic>> _bookedSlots = {};

  // Créneaux horaires disponibles
  final List<TimeOfDay> _timeSlots = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    final reservations = await _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: widget.resource.id)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    Map<DateTime, List<dynamic>> slots = {};
    
    for (var doc in reservations.docs) {
      final data = doc.data();
      DateTime start = (data['startTime'] as Timestamp).toDate();
      DateTime date = DateTime(start.year, start.month, start.day);
      
      if (slots[date] == null) {
        slots[date] = [];
      }
      slots[date]!.add({
        'start': start,
        'end': (data['endTime'] as Timestamp).toDate(),
      });
    }
    
    setState(() {
      _bookedSlots = slots;
    });
  }

  bool _isTimeSlotAvailable(DateTime date, TimeOfDay time) {
    final dayKey = DateTime(date.year, date.month, date.day);
    if (!_bookedSlots.containsKey(dayKey)) return true;
    
    final slotStart = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final slotEnd = slotStart.add(const Duration(hours: 1));
    
    for (var booked in _bookedSlots[dayKey]!) {
      final bookedStart = booked['start'];
      final bookedEnd = booked['end'];
      
      if (slotStart.isBefore(bookedEnd) && slotEnd.isAfter(bookedStart)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _createReservation() async {
    if (_selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un créneau horaire')),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      // Vérifier si le créneau est toujours disponible
      if (!_isTimeSlotAvailable(_selectedDay, _selectedStartTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ce créneau n\'est plus disponible')),
        );
        return;
      }

      // Récupérer le nom de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? user.email?.split('@').first ?? 'Utilisateur';

      // Créer la réservation
      await _firestore.collection('reservations').add({
        'resourceId': widget.resource.id,
        'userId': user.uid,
        'userName': userName,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'status': 'pending',
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver ${widget.resource.name}'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Calendrier
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedStartTime = null;
                          _selectedEndTime = null;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Sélection des horaires
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Text(
                          'Sélectionnez un créneau',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<TimeOfDay>(
                                decoration: const InputDecoration(
                                  labelText: 'Heure de début',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedStartTime,
                                items: _timeSlots.map((slot) {
                                  return DropdownMenuItem(
                                    value: slot,
                                    child: Text(_formatTime(slot)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStartTime = value;
                                    _selectedEndTime = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<TimeOfDay>(
                                decoration: const InputDecoration(
                                  labelText: 'Heure de fin',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedEndTime,
                                items: _selectedStartTime != null
                                    ? _timeSlots
                                        .where((slot) => slot.hour > _selectedStartTime!.hour)
                                        .map((slot) {
                                          return DropdownMenuItem(
                                            value: slot,
                                            child: Text(_formatTime(slot)),
                                          );
                                        }).toList()
                                    : [],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEndTime = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optionnel)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedStartTime != null && _selectedEndTime != null
                                ? _createReservation
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green.shade600,
                            ),
                            child: const Text(
                              'Confirmer la réservation',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}