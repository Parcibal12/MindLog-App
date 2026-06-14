import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journal_dto.dart';
import '../providers/home_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  Color _getEmotionColor(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'ansiedad': return const Color(0xFFF97316);
      case 'calma': return const Color(0xFF14B8A6);
      case 'enojo': return const Color(0xFFA855F7);
      case 'tristeza': return const Color(0xFF3B82F6);
      default: return const Color(0xFF94A3B8);
    }
  }

  IconData _getEmotionIcon(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'ansiedad': return Icons.sentiment_dissatisfied;
      case 'calma': return Icons.sentiment_satisfied_alt;
      case 'enojo': return Icons.sentiment_very_dissatisfied;
      case 'tristeza': return Icons.sentiment_neutral;
      default: return Icons.circle;
    }
  }

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

    // Calcular la grilla del calendario (Días del mes actual)
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8), size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text("Calendario Emocional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)),
                  ),
                  Text("${_focusedMonth.month}/${_focusedMonth.year}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO DEL CALENDARIO DINÁMICO ---
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
                        color: Colors.white, borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), offset: Offset(0, 4), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ["Lu", "Ma", "Mi", "Ju", "Vi", "Sa", "Do"].map((d) => 
                              Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.25))
                            ).toList(),
                          ),
                          const SizedBox(height: 12),
                          
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: totalSlots,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12, crossAxisSpacing: 8),
                            itemBuilder: (context, index) {
                              if (index < emptySlots) return const SizedBox.shrink(); // Espacios vacíos antes del día 1
                              
                              int day = index - emptySlots + 1;
                              DateTime thisDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                              bool isSelected = _selectedDate.year == thisDate.year && _selectedDate.month == thisDate.month && _selectedDate.day == thisDate.day;
                              
                              // Buscar si hay diarios ese día específico
                              var dayEntries = allEntries.where((e) => e.createdAt.toLocal().year == thisDate.year && e.createdAt.toLocal().month == thisDate.month && e.createdAt.toLocal().day == thisDate.day).toList();
                              
                              Color bgColor = const Color(0xFFF1F5F9);
                              Color textColor = const Color(0xFF475569);
                              List<BoxShadow>? shadow;

                              if (isSelected) {
                                bgColor = const Color(0xFF1E293B);
                                textColor = Colors.white;
                              } else if (dayEntries.isNotEmpty) {
                                bgColor = _getEmotionColor(dayEntries.first.emotionName);
                                textColor = Colors.white;
                                shadow = [BoxShadow(color: bgColor.withValues(alpha: 0.3), offset: const Offset(0, 4), blurRadius: 6)];
                              } else if (thisDate.isBefore(DateTime.now())) {
                                textColor = const Color(0xFFCBD5E1); // Días pasados sin registro
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
                              _buildLegendItem(const Color(0xFF14B8A6), "Calma"),
                              _buildLegendItem(const Color(0xFFF97316), "Ansiedad"),
                              _buildLegendItem(const Color(0xFFA855F7), "Enojo"),
                              _buildLegendItem(const Color(0xFF3B82F6), "Tristeza"),
                            ],
                          )
                        ],
                      ),
                    ),

                    // --- ENTRADAS DEL DÍA SELECCIONADO (DINÁMICAS) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      child: Text("Registros del ${_selectedDate.day}/${_selectedDate.month}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    ),
                    
                    if (selectedDayEntries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        child: Text("No hay registros este día.", style: TextStyle(color: Color(0xFF94A3B8))),
                      )
                    else
                      ...selectedDayEntries.map((entry) {
                        final color = _getEmotionColor(entry.emotionName);
                        // Extraemos un solo contexto para mostrar (para evitar overflow)
                        final contextText = entry.contextTagIds.isNotEmpty ? "Contexto Guardado" : "Diario General"; 

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: const [BoxShadow(color: Color(0x08000000), offset: Offset(0, 4), blurRadius: 10)],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: Icon(_getEmotionIcon(entry.emotionName), color: color, size: 20),
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
                                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text(entry.emotionName.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.25)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                          child: Text(contextText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.25)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.content,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatTime(entry.createdAt), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}