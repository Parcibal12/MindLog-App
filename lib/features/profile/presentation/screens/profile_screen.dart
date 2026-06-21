import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import '../providers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool autoSend = true;
  bool darkMode = false;
  bool biometrics = true;
  bool reportSent = false;
  final TextEditingController _emailController = TextEditingController();

  void _handleGenerateReport() async {
    final email = _emailController.text.trim();
    
    if (autoSend) {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debes ingresar el correo del terapeuta"), backgroundColor: Colors.orange),
        );
        return;
      }
      
      final bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      if (!isEmailValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ingresa un correo electrónico válido"), backgroundColor: Colors.orange),
        );
        return;
      }
    }

    final success = await ref.read(profileControllerProvider.notifier)
        .saveProfileAndGenerateReport(email, autoSend);

    if (mounted) {
      if (success) {
        setState(() => reportSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado y reporte enviado"), backgroundColor: Color(0xFF14B8A6)),
        );
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => reportSent = false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al procesar la solicitud"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState is AsyncLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 104,
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8), size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text("Mi Perfil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                            color: const Color(0xFFCCFBF1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                          ),
                          alignment: Alignment.center,
                          child: const Text("D", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daniel Irigoyen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            Text("Estudiante de Ingeniería", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(left: 28, top: 16, bottom: 8),
                    child: Text("CONEXIÓN PROFESIONAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.55)),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                      boxShadow: const [BoxShadow(color: Color(0x07000000), offset: Offset(0, 4), blurRadius: 20)],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2, right: 2,
                          child: Container(
                            width: 96, height: 96,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(96)),
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
                                    decoration: const BoxDecoration(color: Color(0xFFF0FDFA), shape: BoxShape.circle),
                                    child: const Icon(Icons.link, color: Color(0xFF0D9488), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text("Terapeuta vinculado", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(color: Color(0xFFF1F5F9), height: 32, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Envío automático", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                        SizedBox(height: 2),
                                        Text("Comparte un resumen de tus patrones cada domingo por la noche.", style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.25)),
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
                                    color: const Color(0xFFF0FDFA),
                                    border: Border.all(color: const Color(0xFF99F6E4)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoading)
                                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF0D9488), strokeWidth: 2))
                                      else ...[
                                        Text(
                                          reportSent ? "✓ Reporte enviado" : "Guardar y generar ahora",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                        ),
                                        if (!reportSent) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.chevron_right, color: Color(0xFF0D9488), size: 18),
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

                  const Padding(
                    padding: EdgeInsets.only(left: 28, top: 24, bottom: 8),
                    child: Text("APLICACIÓN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.55)),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: const [BoxShadow(color: Color(0x07000000), offset: Offset(0, 4), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        MindLogSettingTile(
                          icon: Icons.dark_mode_outlined,
                          title: "Modo Oscuro",
                          trailing: MindLogSwitch(value: darkMode, onChanged: (val) => setState(() => darkMode = val)),
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
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                            SizedBox(width: 8),
                            Text("Cerrar Sesión", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Center(
                    child: Text("MindLog v2.0 - Multiplataforma", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
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