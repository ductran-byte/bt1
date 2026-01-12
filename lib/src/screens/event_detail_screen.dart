import 'package:bt1/src/models/event.dart';
import 'package:bt1/src/services/api_service.dart';
import 'package:bt1/src/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(ApiService.getFullImageUrl(event.imageUrl), fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip(Icons.calendar_month_rounded, DateFormat('EEEE, MMM dd').format(event.dateTime ?? DateTime.now()), Colors.orangeAccent),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.access_time_filled_rounded, DateFormat('hh:mm a').format(event.dateTime ?? DateTime.now()), Colors.blueAccent),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('THE EXPERIENCE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 17, height: 1.8, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 25, backgroundColor: Colors.deepPurpleAccent, child: Icon(Icons.location_on_rounded, color: Colors.white)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Global Tech Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Innovation Center, Floor 42', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Colors.deepPurpleAccent, Colors.pinkAccent]),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ĐÃ SỬA: Gửi ID sự kiện đi cùng yêu cầu chuyển tab
              NavigationService.jumpToRegisterWithEvent(event.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
            child: const Text('READY TO JOIN?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
