// lib/widgets/reservation_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_booking/models/resource_model.dart';
import 'package:flutter_booking/services/auth_service.dart';

class ReservationModal extends StatefulWidget {
  final ResourceModel resource;
  final Function onReservationCreated;

  const ReservationModal({
    super.key,
    required this.resource,
    required this.onReservationCreated,
  });

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = false;

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

  Future<void> _checkAvailability() async {
    if (_selectedStartTime == null || _selectedEndTime == null) return;
    
    setState(() => _isChecking = true);
    
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );
    
    final existingReservations = await _firestore
        .collection('reservations')
        .where('resourceId', isEqualTo: widget.resource.id)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();
    
    bool isAvailable = true;
    for (var doc in existingReservations.docs) {
      final data = doc.data();
      final existingStart = (data['startTime'] as Timestamp).toDate();
      final existingEnd = (data['endTime'] as Timestamp).toDate();
      
      if (startDateTime.isBefore(existingEnd) && endDateTime.isAfter(existingStart)) {
        isAvailable = false;
        break;
      }
    }
    
    setState(() => _isChecking = false);
    
    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce créneau n\'est pas disponible'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Créneau disponible !'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? user.email?.split('@').first ?? 'Utilisateur';

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

      widget.onReservationCreated();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
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

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    Row(
                      children: [
                        Icon(Icons.book_online, color: Colors.blue.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Réserver ${widget.resource.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    
                    const SizedBox(height: 16),
                    
                    // Sélection de la date
                    const Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                          _selectedStartTime = null;
                          _selectedEndTime = null;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sélection des horaires
                    const Text(
                      'Horaires',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TimeOfDay>(
                            decoration: const InputDecoration(
                              labelText: 'Début',
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
                              labelText: 'Fin',
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
                    
                    // Bouton vérifier disponibilité
                    if (_selectedStartTime != null && _selectedEndTime != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isChecking ? null : _checkAvailability,
                            icon: _isChecking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle),
                            label: Text(_isChecking ? 'Vérification...' : 'Vérifier disponibilité'),
                          ),
                        ),
                      ),
                    
                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bouton de confirmation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedStartTime != null && _selectedEndTime != null)
                            ? _createReservation
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
      ),
    );
  }
}