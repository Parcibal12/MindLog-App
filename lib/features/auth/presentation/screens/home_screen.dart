import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sábado, 8 Dic".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSubtitle,
                          letterSpacing: 0.55,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Hola, Daniel",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeader,
                        ),
                      ),
                    ],
                  ),
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "D",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CUERPO (Estado Vacío Fijo Temporalmente) ---
            const Expanded(
              child: _EmptyState(),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_filled, color: AppColors.primaryDark),
                Text("Inicio", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ],
            ),
            SizedBox(width: 48),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, color: AppColors.textSubtitle),
                Text("Reportes", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSubtitle)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(color: Color(0x3314B8A6), blurRadius: 20)
              ],
            ),
            child: const Icon(Icons.eco_outlined, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            "Tu lienzo en blanco",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHeader),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "Aún no hay registros hoy. Tómate un momento para escribir cómo te sientes. Tu mente te lo agradecerá.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          const Column(
            children: [
              Text("COMENZAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5EEAD4), letterSpacing: 1)),
              SizedBox(height: 4),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF5EEAD4)),
            ],
          )
        ],
      ),
    );
  }
}