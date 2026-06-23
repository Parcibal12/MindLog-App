import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import '../../../../core/platform/device_info_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool autoSend = true;
  bool biometrics = true;
  bool reportSent = false;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('privacyVault');
    final savedEmail = box.get('therapist_email', defaultValue: '');
    _emailController = TextEditingController(text: savedEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleGenerateReport() async {
    final email = _emailController.text.trim();
    
    if (autoSend) {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debes ingresar el correo del terapeuta"), backgroundColor: AppColors.warningMode),
        );
        return;
      }
      
      final bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      if (!isEmailValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ingresa un correo electrónico válido"), backgroundColor: AppColors.warningMode),
        );
        return;
      }
    }

    final success = await ref.read(profileControllerProvider.notifier)
        .saveProfileAndGenerateReport(email, autoSend);

    if (mounted) {
      if (success) {
        Hive.box('privacyVault').put('therapist_email', email);
        setState(() => reportSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado y reporte enviado"), backgroundColor: AppColors.primaryGreen),
        );
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => reportSent = false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al procesar la solicitud"), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState is AsyncLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentThemeMode = ref.watch(themeProvider);
    final isDarkModeActive = currentThemeMode == ThemeMode.dark;

    final deviceNameAsync = ref.watch(deviceNameProvider);
    final osVersionAsync = ref.watch(osVersionProvider);
    
    final deviceInfoText = deviceNameAsync.when(
      data: (name) => osVersionAsync.when(
        data: (os) => 'MindLog v2.0 - Corriendo en $name ($os)',
        loading: () => 'MindLog v2.0 - Obteniendo info...',
        error: (_, __) => 'MindLog v2.0 - Multiplataforma',
      ),
      loading: () => 'MindLog v2.0 - Obteniendo info...',
      error: (_, __) => 'MindLog v2.0 - Multiplataforma',
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 104,
            child: Container(
              color: isDark ? AppColors.darkBackground : AppColors.backgroundWhite,
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text("Mi Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                ],
              ),
            ),
          ),

          Positioned.fill(
            top: 104,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkAvatarBackground : AppColors.avatarBorder,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.primaryDark : Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 1), blurRadius: 1)],
                          ),
                          alignment: Alignment.center,
                          child: Text("D", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daniel Irigoyen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                            Text("Estudiante de Ingeniería", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 16, bottom: 8),
                    child: Text("CONEXIÓN PROFESIONAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.55)),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.avatarBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 4), blurRadius: 20)],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2, right: 2,
                          child: Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkAvatarBackground : AppColors.avatarBackground,
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(96)),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: isDark ? AppColors.darkAvatarBackground : AppColors.avatarBackground, shape: BoxShape.circle),
                                    child: Icon(Icons.link, color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text("Terapeuta vinculado", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: MindLogTextField(
                                controller: _emailController,
                                hintText: "Correo del terapeuta",
                                prefixIcon: Icons.email_outlined,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight, height: 32, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Envío automático", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                                        const SizedBox(height: 2),
                                        Text("Comparte un resumen de tus patrones cada domingo por la noche.", style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, height: 1.25)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  MindLogSwitch(
                                    value: autoSend,
                                    onChanged: (val) => setState(() => autoSend = val),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: InkWell(
                                onTap: isLoading ? null : _handleGenerateReport,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkAvatarBackground : AppColors.avatarBackground,
                                    border: Border.all(color: isDark ? AppColors.primaryDark : AppColors.secondaryGreen),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoading)
                                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark, strokeWidth: 2))
                                      else ...[
                                        Text(
                                          reportSent ? "✓ Reporte enviado" : "Guardar y generar ahora",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark),
                                        ),
                                        if (!reportSent) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.chevron_right, color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark, size: 18),
                                        ]
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 24, bottom: 8),
                    child: Text("APLICACIÓN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.55)),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), offset: const Offset(0, 4), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        MindLogSettingTile(
                          icon: Icons.dark_mode_outlined,
                          title: "Modo Oscuro",
                          trailing: MindLogSwitch(
                            value: isDarkModeActive, 
                            onChanged: (_) {
                              ref.read(themeProvider.notifier).toggleTheme();
                            }
                          ),
                        ),
                        MindLogSettingTile(
                          showTopDivider: true,
                          icon: Icons.fingerprint,
                          title: "Acceso con Huella / FaceID",
                          trailing: MindLogSwitch(value: biometrics, onChanged: (val) => setState(() => biometrics = val)),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: InkWell(
                      onTap: () {}, 
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), offset: const Offset(0, 1), blurRadius: 1)],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColors.errorRed, size: 18),
                            SizedBox(width: 8),
                            Text("Cerrar Sesión", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Text(deviceInfoText, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}