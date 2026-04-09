// lib/views/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ──────────────────────────────────────────────────────
          Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Text(
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          // ── Cartes statistiques ─────────────────────────────────────
          _StatsGrid(),

          const SizedBox(height: 24),

          // ── Réservations récentes ───────────────────────────────────
          _SectionHeader('Réservations récentes'),
          const SizedBox(height: 12),
          _RecentReservations(),

          const SizedBox(height: 24),

          // ── Ressources les plus réservées ───────────────────────────
          _SectionHeader('Ressources les plus demandées'),
          const SizedBox(height: 12),
          _TopResources(),

          const SizedBox(height: 24),

          // ── Répartition par statut ──────────────────────────────────
          _SectionHeader('Répartition des réservations'),
          const SizedBox(height: 12),
          _StatusBreakdown(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Grille 4 stats ──────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Ressources',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue,
          stream: firestore
              .collection('resources')
              .snapshots()
              .map((s) => s.docs.length),
        ),
        _StatCard(
          label: 'Utilisateurs',
          icon: Icons.people_outline,
          color: Colors.purple,
          stream: firestore
              .collection('users')
              .snapshots()
              .map((s) => s.docs.length),
        ),
        _StatCard(
          label: 'En attente',
          icon: Icons.pending_actions,
          color: Colors.orange,
          stream: firestore
              .collection('reservations')
              .where('status', isEqualTo: 'pending')
              .snapshots()
              .map((s) => s.docs.length),
        ),
        _StatCard(
          label: 'Confirmées',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          stream: firestore
              .collection('reservations')
              .where('status', isEqualTo: 'confirmed')
              .snapshots()
              .map((s) => s.docs.length),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Stream<int> stream;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.hasData ? '${snapshot.data}' : '—',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Réservations récentes ────────────────────────────────────────────────────

class _RecentReservations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _EmptyState('Aucune réservation pour l\'instant');
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'pending';
            final userName = data['userName'] as String? ?? 'Inconnu';
            final createdAt = data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now();

            return _ReservationRow(
              userName: userName,
              status: status,
              date: createdAt,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReservationRow extends StatelessWidget {
  final String userName;
  final String status;
  final DateTime date;

  const _ReservationRow({
    required this.userName,
    required this.status,
    required this.date,
  });

  Color get _color {
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

  String get _label {
    switch (status) {
      case 'confirmed':
        return 'Confirmée';
      case 'cancelled':
        return 'Annulée';
      case 'rejected':
        return 'Rejetée';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date),
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _label,
              style: TextStyle(
                  fontSize: 11,
                  color: _color,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top ressources ───────────────────────────────────────────────────────────

class _TopResources extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('reservations')
          .where('status', whereIn: ['confirmed', 'pending']).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Compter les réservations par ressource
        final Map<String, int> counts = {};
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final rid = data['resourceId'] as String? ?? '';
          if (rid.isNotEmpty) counts[rid] = (counts[rid] ?? 0) + 1;
        }

        if (counts.isEmpty) {
          return _EmptyState('Aucune donnée disponible');
        }

        // Trier et prendre les 4 premiers
        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(4).toList();
        final maxVal = top.first.value;

        return Column(
          children: top.map((entry) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('resources')
                  .doc(entry.key)
                  .get(),
              builder: (context, snap) {
                final name = snap.hasData && snap.data!.exists
                    ? (snap.data!.data()
                            as Map<String, dynamic>)['name'] as String? ??
                        'Ressource'
                    : 'Ressource';
                final pct = entry.value / maxVal;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text('${entry.value} rés.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Répartition par statut ───────────────────────────────────────────────────

class _StatusBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('pending', 'En attente', Colors.orange),
      ('confirmed', 'Confirmées', Colors.green),
      ('cancelled', 'Annulées', Colors.red),
      ('rejected', 'Rejetées', Colors.grey),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: statuses.map((s) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservations')
                .where('status', isEqualTo: s.$1)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: s.$3, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.$2,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: s.$3,
                          fontSize: 15),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ),
    );
  }
}
