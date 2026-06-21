import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';

final pinProvider = StateProvider<String>((ref) => '');

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _addDigit(String digit, WidgetRef ref) {
    final current = ref.read(pinProvider);
    if (current.length < 4) ref.read(pinProvider.notifier).state = current + digit;
  }

  void _removeDigit(WidgetRef ref) {
    final current = ref.read(pinProvider);
    if (current.isNotEmpty) ref.read(pinProvider.notifier).state = current.substring(0, current.length - 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pin = ref.watch(pinProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 600;
          
          return Center(
            child: Container(
              width: isWeb ? 400 : double.infinity,
              height: isWeb ? 850 : double.infinity,
              decoration: isWeb ? BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)
                ],
              ) : null,
              child: ClipRRect(
                borderRadius: isWeb ? BorderRadius.circular(40) : BorderRadius.zero,
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Transform.rotate(
                                angle: 3 * 3.14159 / 180,
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  width: 116,
                                  height: 116,
                                  fit: BoxFit.contain, 
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                "Bienvenido de nuevo",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textHeader),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Ingresa tu PIN para continuar",
                                style: TextStyle(fontSize: 14, color: AppColors.textSubtitle),
                              ),
                              const SizedBox(height: 40),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (index) {
                                  bool isFilled = index < pin.length;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 11),
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled ? AppColors.primaryGreen : AppColors.indicatorInactive,
                                      boxShadow: isFilled ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 1), blurRadius: 2)] : null,
                                    ),
                                  );
                                }),
                              ),
                              
                              const SizedBox(height: 32),
                              TextButton(
                                onPressed: () {},
                                child: const Text("¿Olvidaste tu PIN?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.3)),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      MindLogNumPad(
                        onDigitTap: (digit) => _addDigit(digit, ref),
                        onBackspaceTap: () => _removeDigit(ref),
                        onBiometricTap: () {
                        },
                        showBiometrics: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}