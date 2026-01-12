import 'package:bt1/src/models/event.dart';
import 'package:bt1/src/services/api_service.dart';
import 'package:bt1/src/services/navigation_service.dart'; // Đã thêm import
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  String _name = '';
  String _email = '';
  String _phone = '';
  int? _selectedEventId;
  bool _isLoading = false;

  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    
    // ĐÃ THÊM: Lắng nghe sự kiện được chọn sẵn từ service
    NavigationService.preSelectedEventIdNotifier.addListener(_handlePreSelectedEvent);
  }

  @override
  void dispose() {
    // Đừng quên gỡ bỏ listener khi không dùng nữa
    NavigationService.preSelectedEventIdNotifier.removeListener(_handlePreSelectedEvent);
    super.dispose();
  }

  // Hàm xử lý khi có sự kiện được chọn sẵn
  void _handlePreSelectedEvent() {
    final preSelectedId = NavigationService.preSelectedEventIdNotifier.value;
    if (preSelectedId != null && mounted) {
      setState(() {
        _selectedEventId = preSelectedId;
      });
      // Đặt lại giá trị về null để không lặp lại việc chọn sẵn ở lần sau (nếu cần)
      // NavigationService.preSelectedEventIdNotifier.value = null;
    }
  }

  Future<void> _loadEvents() async {
    try {
      final result = await _apiService.fetchEvents(page: 1, pageSize: 100);
      if (mounted) {
        setState(() {
          _events = result.events;
          // Kiểm tra xem ID chọn sẵn đã có trong danh sách vừa tải chưa
          final preSelectedId = NavigationService.preSelectedEventIdNotifier.value;
          if (preSelectedId != null) {
            _selectedEventId = preSelectedId;
          }
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await _apiService.submitRegistration(_name, _email, _phone, _selectedEventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registration Successful! ✨'),
              backgroundColor: Colors.greenAccent[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _formKey.currentState!.reset();
          setState(() {
            _selectedEventId = null;
            // Xóa ID chọn sẵn sau khi đăng ký thành công
            NavigationService.preSelectedEventIdNotifier.value = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.stars_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'SECURE YOUR SPOT',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const Text(
                'Join the tech revolution today',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                        onSaved: (v) => _name = v!,
                        validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Email Address',
                        icon: Icons.alternate_email_rounded,
                        onSaved: (v) => _email = v!,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Phone Number',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => _phone = v!,
                        validator: (v) => (v == null || v.length < 10) ? 'Invalid phone' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: _selectedEventId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Tech Event',
                          prefixIcon: const Icon(Icons.event_note_rounded, color: Colors.deepPurple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.deepPurple[50],
                        ),
                        items: _events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setState(() => _selectedEventId = v),
                        validator: (v) => v == null ? 'Please select an event' : null,
                      ),
                      const SizedBox(height: 40),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.pinkAccent]),
                                boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                ),
                                child: const Text('CONFIRM REGISTRATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, required FormFieldSetter<String> onSaved, required FormFieldValidator<String> validator, TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.deepPurple[50],
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
