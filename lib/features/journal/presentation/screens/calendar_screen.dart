import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import '../providers/home_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final allEntries = entriesAsync.value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; 
    final emptySlots = firstWeekday - 1; 
    final totalSlots = emptySlots + daysInMonth;

    final selectedDayEntries = allEntries.where((e) {
      final local = e.createdAt.toLocal();
      return local.year == _selectedDate.year && local.month == _selectedDate.month && local.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text("Calendario Emocional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)),
                  ),
                  Text("${_focusedMonth.month}/${_focusedMonth.year}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 4), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ["Lu", "Ma", "Mi", "Ju", "Vi", "Sa", "Do"].map((d) => 
                              Text(d, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.25))
                            ).toList(),
                          ),
                          const SizedBox(height: 12),
                          
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: totalSlots,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 8),
                            itemBuilder: (context, index) {
                              if (index < emptySlots) return const SizedBox.shrink(); 
                              
                              int day = index - emptySlots + 1;
                              DateTime thisDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                              bool isSelected = _selectedDate.year == thisDate.year && _selectedDate.month == thisDate.month && _selectedDate.day == thisDate.day;
                              
                              var dayEntries = allEntries.where((e) => e.createdAt.toLocal().year == thisDate.year && e.createdAt.toLocal().month == thisDate.month && e.createdAt.toLocal().day == thisDate.day).toList();
                              
                              Color bgColor = isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight;
                              Color textColor = isDark ? AppColors.darkTextSubtitle : AppColors.textNumber;
                              List<BoxShadow>? shadow;

                              if (isSelected) {
                                bgColor = isDark ? AppColors.primaryDark : AppColors.textHeader;
                                textColor = Colors.white;
                              } else if (dayEntries.isNotEmpty) {
                                bgColor = EmotionThemeMapper.getPalette(dayEntries.first.emotionName).main;
                                textColor = Colors.white;
                                shadow = [BoxShadow(color: bgColor.withValues(alpha: 0.3), offset: const Offset(0, 4), blurRadius: 6)];
                              } else if (thisDate.isBefore(DateTime.now())) {
                                textColor = isDark ? AppColors.darkBackground : const Color(0xFFCBD5E1); 
                              }

                              return GestureDetector(
                                onTap: () => setState(() => _selectedDate = thisDate),
                                child: Container(
                                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, boxShadow: shadow),
                                  alignment: Alignment.center,
                                  child: Text(day.toString(), style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: textColor)),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
                            children: [
                              _buildLegendItem(AppColors.primaryGreen, "Calma", isDark),
                              _buildLegendItem(AppColors.anxietyOrange, "Ansiedad", isDark),
                              _buildLegendItem(AppColors.angerPurple, "Enojo", isDark),
                              _buildLegendItem(AppColors.sadnessBlue, "Tristeza", isDark),
                            ],
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      child: Text("Registros del ${_selectedDate.day}/${_selectedDate.month}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)),
                    ),
                    
                    if (selectedDayEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        child: Text("No hay registros este día.", style: TextStyle(color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
                      )
                    else
                      ...selectedDayEntries.map((entry) {
                        final palette = EmotionThemeMapper.getPalette(entry.emotionName);
                        final contextText = entry.contextTagIds.isNotEmpty ? "Contexto Guardado" : "Diario General"; 

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), offset: const Offset(0, 4), blurRadius: 10)],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: palette.lightBackground, shape: BoxShape.circle),
                                child: Icon(palette.icon, color: palette.main, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8, runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: palette.lightBackground, borderRadius: BorderRadius.circular(6)),
                                          child: Text(entry.emotionName.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: palette.main, letterSpacing: 0.25)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: isDark ? AppColors.darkIndicatorInactive : AppColors.borderLight, borderRadius: BorderRadius.circular(6)),
                                          child: Text(contextText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.25)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.content,
                                      style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber, height: 1.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatTime(entry.createdAt), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
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