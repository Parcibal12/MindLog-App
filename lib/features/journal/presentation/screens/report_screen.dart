import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';
import '../providers/report_controller.dart';
import '../providers/home_controller.dart';
import '../../data/models/journal_dto.dart';
import 'home_screen.dart';
import 'editor_screen.dart';
import 'calendar_screen.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  Color _getEmotionColor(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'ansiedad': return const Color(0xFFF97316);
      case 'calma': return const Color(0xFF14B8A6);
      case 'enojo': return const Color(0xFFA855F7);
      case 'tristeza': return const Color(0xFF3B82F6);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final entriesState = ref.watch(journalEntriesProvider); 
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mis Patrones", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 1, offset: Offset(0, 1))],
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF94A3B8), size: 20),
                  ),
                ],
              ),
            ),

            Expanded(
              child: analyticsState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                data: (data) {
                  final mainTrigger = data.topDisparadores.isNotEmpty ? data.topDisparadores[0].tagName : 'No hay datos';
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0F766E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [BoxShadow(color: Color(0x3314B8A6), offset: Offset(0, 10), blurRadius: 15)],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: -24, right: -24,
                                child: Container(width: 128, height: 128, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.psychology, color: Color(0xFFCCFBF1), size: 24),
                                    const SizedBox(height: 8),
                                    const Text("PATRÓN DETECTADO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF0FDFA), letterSpacing: 0.5)),
                                    const SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500, height: 1.3),
                                        children: [
                                          const TextSpan(text: "Tu "),
                                          TextSpan(text: data.dominantEmotion.toLowerCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                                          const TextSpan(text: " ocurre principalmente cuando estás en: "),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                          child: Text(mainTrigger, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen())),
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: Color(0xFF94A3B8), size: 20),
                                    SizedBox(width: 12),
                                    Text("Mapa de Humor (Esta Semana)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: ["L", "M", "M", "J", "V", "S", "D"].map((d) => 
                                    Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))
                                  ).toList(),
                                ),
                                const SizedBox(height: 8),

                                entriesState.maybeWhen(
                                  data: (entries) {
                                    final now = DateTime.now();
                                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                                    
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: List.generate(7, (index) {
                                        final currentDay = startOfWeek.add(Duration(days: index));
                                        final dayEntries = entries.where((e) => e.createdAt.toLocal().day == currentDay.day && e.createdAt.toLocal().month == currentDay.month).toList();
                                        
                                        if (dayEntries.isEmpty) {
                                          return _buildDot(color: const Color(0xFFF1F5F9)); // Día vacío (Gris claro)
                                        } else {
                                          final color = _getEmotionColor(dayEntries.first.emotionName);
                                          return _buildDot(color: color, shadow: color.withValues(alpha: 0.3)); // Día con diario
                                        }
                                      }),
                                    );
                                  },
                                  orElse: () => const CircularProgressIndicator(),
                                ),
                                
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    const Text("Ansiedad", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                    const SizedBox(width: 16),
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF14B8A6), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    const Text("Calma", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Color(0xFF94A3B8), size: 20),
                                  SizedBox(width: 12),
                                  Text("Disparadores Frecuentes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              if (data.topDisparadores.isEmpty)
                                const Text("Aún no hay suficientes datos.", style: TextStyle(color: Color(0xFF94A3B8))),
                              
                              ...data.topDisparadores.map((tag) {
                                final double percentage = data.totalEntries > 0 ? (tag.count / data.totalEntries) * 100 : 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(tag.tagName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                          Text(tag.count.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 10, width: double.infinity,
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: percentage > 1 ? 1 : percentage,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: data.topDisparadores.indexOf(tag) % 2 == 0 ? const Color(0xFFF97316) : const Color(0xFF14B8A6), 
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditorScreen())),
        backgroundColor: AppColors.primaryGreen,
        elevation: 8, shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, shape: const CircularNotchedRectangle(), notchMargin: 8.0, height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, color: AppColors.textSubtitle),
                  Text("Inicio", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSubtitle)),
                ],
              ),
            ),
            const SizedBox(width: 48),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, color: AppColors.primaryDark),
                Text("Reportes", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required Color color, Color? shadow}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shadow != null ? [BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 6)] : null,
      ),
    );
  }
}