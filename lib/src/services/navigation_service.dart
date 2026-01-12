import 'package:flutter/material.dart';

class NavigationService {
  // Thông báo thay đổi tab
  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  // ĐÃ THÊM: Thông báo ID sự kiện được chọn sẵn
  static final ValueNotifier<int?> preSelectedEventIdNotifier = ValueNotifier<int?>(null);

  // Hàm chuyển tab
  static void switchTab(int index) {
    selectedTabNotifier.value = index;
  }

  // ĐÃ THÊM: Hàm chuyển sang tab Register và chọn sẵn Event
  static void jumpToRegisterWithEvent(int eventId) {
    preSelectedEventIdNotifier.value = eventId;
    selectedTabNotifier.value = 2; // Index của tab Register
  }
}
