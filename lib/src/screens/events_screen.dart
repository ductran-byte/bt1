import 'package:bt1/src/models/category.dart';
import 'package:bt1/src/screens/event_detail_screen.dart';
import 'package:bt1/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:bt1/src/models/event.dart'; 
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService();
  final List<Event> _events = [];
  List<Category> _categories = [];
  final ScrollController _scrollController = ScrollController();
  
  static const int _pageSize = 5; 
  int _page = 1;
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.fetchCategories();
      if (mounted) setState(() => _categories = categories);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _fetchEvents({bool isRefresh = false}) async {
    if (_isLoading) return;
    
    if (isRefresh) {
      setState(() {
        _page = 1;
        _events.clear();
        _hasNextPage = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.fetchEvents(
        page: _page, 
        pageSize: _pageSize, 
        categoryId: _selectedCategoryId
      );
      
      if (mounted) {
        setState(() {
          _events.addAll(result.events);
          _page++;
          _hasNextPage = _page <= result.pageCount;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _hasNextPage = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('EXPLORE EVENTS'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.withOpacity(0.1), Colors.white.withOpacity(0.1)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F2FF), Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            _buildCategoryFilters(),
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty && _isLoading) return const SizedBox.shrink();
    return SizedBox(
      height: 70,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isSelected = index == 0 ? _selectedCategoryId == null : _selectedCategoryId == _categories[index - 1].id;
          final name = index == 0 ? 'All Events' : _categories[index - 1].name;
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() => _selectedCategoryId = index == 0 ? null : _categories[index - 1].id);
                _fetchEvents(isRefresh: true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected 
                    ? const LinearGradient(colors: [Colors.deepPurpleAccent, Colors.pinkAccent])
                    : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
                ),
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.deepPurple[900], fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    if (_isLoading && _events.isEmpty) return const Center(child: CircularProgressIndicator());

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No Events Found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchEvents(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _events.length + (_hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) {
            // Hiển thị nút Load More rực rỡ ở cuối danh sách
            return _buildLoadMoreButton();
          }
          return EventCard(event: _events[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.pinkAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _fetchEvents(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'LOAD MORE MAGIC',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Hero(
                tag: 'event-img-${event.id}',
                child: Image.network(
                  ApiService.getFullImageUrl(event.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => Container(color: Colors.deepPurple[50]),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: Text(
                  DateFormat('dd\nMMM').format(event.dateTime ?? DateTime.now()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 25, left: 25, right: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => EventDetailScreen(event: event))),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple, minimumSize: const Size(120, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
