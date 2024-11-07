import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/presentation/resources/font_manager.dart';

import '../../app/routes_manager.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  _startDelay() {
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  _goNext() {
    Navigator.pushReplacementNamed(context, Routes.mainRoute);
  }

  @override
  void initState() {
    super.initState();
    _startDelay();
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      body: Center(
        child: Text("Welcome",
          style: getRegularStyle(color: ColorManager.white,
            fontSize: FontSize.s22
          ),
        ),
      ),
    );
  }
}
