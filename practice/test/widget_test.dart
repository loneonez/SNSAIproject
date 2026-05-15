import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LiquidGlassView(
          backgroundWidget: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
          children: [
            LiquidGlass(
              width: 200,
              height: 100,
              magnification: 1,
              distortion: 0.1,
              distortionWidth: 50,
              position: LiquidGlassAlignPosition(alignment: Alignment.center),
            ),
          ],
        ),
      ),
    );
  }
}
