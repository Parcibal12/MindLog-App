import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

final pinProvider = StateProvider<String>((ref) => '');

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

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

                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceKeyboard,
                          border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.8)),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRow(['1', '2', '3'], ref),
                            const SizedBox(height: 8),
                            _buildRow(['4', '5', '6'], ref),
                            const SizedBox(height: 8),
                            _buildRow(['7', '8', '9'], ref),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _KeyButton(onTap: () {}, child: const Icon(Icons.fingerprint, color: AppColors.primaryDark, size: 32)),
                                _KeyButton(onTap: () => _addDigit('0', ref), child: const Text('0', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textNumber))),
                                _KeyButton(onTap: () => _removeDigit(ref), child: const Icon(Icons.backspace_outlined, color: AppColors.textSubtitle, size: 24)),
                              ],
                            ),
                          ],
                        ),
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

  void _addDigit(String digit, WidgetRef ref) {
    final current = ref.read(pinProvider);
    if (current.length < 4) ref.read(pinProvider.notifier).state = current + digit;
  }

  void _removeDigit(WidgetRef ref) {
    final current = ref.read(pinProvider);
    if (current.isNotEmpty) ref.read(pinProvider.notifier).state = current.substring(0, current.length - 1);
  }

  Widget _buildRow(List<String> digits, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _KeyButton(
        onTap: () => _addDigit(d, ref),
        child: Text(d, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textNumber)),
      )).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeyButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), offset: const Offset(0, 2), blurRadius: 4)],
        ),
        child: Material(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceKeyboard),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}