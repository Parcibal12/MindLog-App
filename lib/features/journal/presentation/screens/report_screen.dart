import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'package:mindlog_app/core/utils/date_formatter.dart';
import '../providers/report_controller.dart';
import '../providers/home_controller.dart';
import '../providers/journal_draft_provider.dart';
import 'dart:math';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final entriesState = ref.watch(journalEntriesProvider); 
    final emotionsState = ref.watch(emotionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mis Patrones", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surfaceLight, 
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
                    ),
                    child: Icon(Icons.filter_list, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, size: 20),
                  ),
                ],
              ),
            ),

            Expanded(
              child: analyticsState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: AppColors.errorRed))),
                data: (data) {
                  final mainTrigger = data.topDisparadores.isNotEmpty ? data.topDisparadores[0].tagName : 'No hay datos';
                  final mainPalette = EmotionThemeMapper.getPalette(data.dominantEmotion);
                  
                  final int maxTriggerCount = data.topDisparadores.isNotEmpty 
                      ? data.topDisparadores.map((t) => t.count).reduce(max) 
                      : 1;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: mainPalette.gradient, 
                              begin: Alignment.topLeft, 
                              end: Alignment.bottomRight
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: mainPalette.shadow, offset: const Offset(0, 10), blurRadius: 15)],
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
                                    const Icon(Icons.lightbulb_outline, color: AppColors.avatarBorder, size: 28),
                                    const SizedBox(height: 8),
                                    const Text("PATRÓN DETECTADO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.avatarBackground, letterSpacing: 0.5)),
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
                          onTap: () => context.push('/calendar'),
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), offset: const Offset(0, 1), blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, size: 20),
                                    const SizedBox(width: 12),
                                    Text("Mapa de Humor (Esta Semana)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: DateFormatter.weekDaysInitials.map((d) => 
                                    Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle))
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
                                          return _buildDot(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight); 
                                        } else {
                                          final dotPalette = EmotionThemeMapper.getPalette(dayEntries.first.emotionName);
                                          return _buildDot(color: dotPalette.main, shadow: dotPalette.shadow); 
                                        }
                                      }),
                                    );
                                  },
                                  orElse: () => const CircularProgressIndicator(),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: emotionsState.when(
                                    loading: () => const Center(
                                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    ),
                                    error: (err, _) => const Text("Error al cargar leyenda", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.errorRed)),
                                    data: (emotions) {
                                      return Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 16, runSpacing: 8,
                                        children: emotions.map((em) {
                                          final label = em.name[0].toUpperCase() + em.name.substring(1).toLowerCase();
                                          return _buildLegendItem(EmotionThemeMapper.getPalette(em.name).main, label, isDark);
                                        }).toList(),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surfaceLight, 
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), offset: const Offset(0, 1), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, size: 20),
                                  const SizedBox(width: 12),
                                  Text("Disparadores Frecuentes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              if (data.topDisparadores.isEmpty)
                                Text("Aún no hay suficientes datos.", style: TextStyle(color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
                              
                              ...data.topDisparadores.map((tag) {
                                final double fillRatio = (tag.count / maxTriggerCount).clamp(0.0, 1.0);
                                final tagPalette = EmotionThemeMapper.getPalette(tag.dominantEmotion);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(tag.tagName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                                          Text(tag.count.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 10, width: double.infinity,
                                        decoration: BoxDecoration(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight, borderRadius: BorderRadius.circular(10)),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: fillRatio,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: tagPalette.main.withValues(alpha: data.topDisparadores.indexOf(tag) % 2 == 0 ? 1.0 : 0.6), 
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

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
      ],
    );
  }
}