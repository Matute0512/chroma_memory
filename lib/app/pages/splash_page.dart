import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';
import '../router.dart';

/// Pantalla de marca (splash) de Chroma Memory.
///
/// Muestra el lockup con un fade+scale corto y reemplaza a la Home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: <Color>[AppPalette.ambientTop, AppPalette.voidBg],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(_fade),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppPalette.ctaGradient,
                      boxShadow: AppPalette.glow(
                        AppPalette.brand,
                        blur: 26,
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CHROMA MEMORY',
                    style: TextStyle(
                      fontFamily: AppPalette.fontDisplay,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.12,
                      color: AppPalette.textHigh,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Memorizá secuencias de colores',
                    style: TextStyle(
                      fontFamily: AppPalette.fontUi,
                      fontSize: 13,
                      color: AppPalette.textMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
