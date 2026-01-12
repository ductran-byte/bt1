import 'dart:async';
import 'package:bt1/src/screens/app_shell.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng Fade In
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // Điều hướng sau 3 giây
    Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppShell()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ĐÃ THAY ĐỔI: Sử dụng Image.asset thay vì FlutterLogo
              // Hãy đảm bảo bạn đã thêm file vào thư mục assets/logo.png và khai báo trong pubspec.yaml
              Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  // Nếu chưa có file ảnh, hiển thị FlutterLogo tạm thời để không bị lỗi app
                  return const FlutterLogo(size: 100);
                },
              ), 
              const SizedBox(height: 24),
              Text(
                'Global Tech Solutions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
