import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';
import '../providers/home_controller.dart';
import '../../data/models/journal_dto.dart';
import 'editor_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getCurrentFormattedDate() {
    final now = DateTime.now();
    final weekdays = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
    final months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
    return "${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsyncValue = ref.watch(journalEntriesProvider);

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
                        _getCurrentFormattedDate().toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 0.55),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Hola, Daniel",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHeader),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                    ),
                    alignment: Alignment.center,
                    child: const Text("D", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: entriesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (err, stack) => Center(child: Text("Error al cargar datos: $err")),
                data: (entries) {
                  if (entries.isEmpty) return const _EmptyState();
                  return _FilledState(entries: entries);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditorScreen())),
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

class _FilledState extends StatelessWidget {
  final List<JournalDto> entries;

  const _FilledState({required this.entries});

  String _calculateDominantEmotion() {
    if (entries.isEmpty) return "Ninguna";
    final Map<String, int> frequencyMap = {};
    for (var entry in entries) {
      frequencyMap[entry.emotionName] = (frequencyMap[entry.emotionName] ?? 0) + 1;
    }
    String dominant = frequencyMap.keys.first;
    int maxCount = frequencyMap[dominant]!;
    frequencyMap.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = emotion;
      }
    });
    return dominant;
  }

  Map<String, List<JournalDto>> _groupEntriesByDate() {
    final Map<String, List<JournalDto>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var entry in entries) {
      final localDate = entry.createdAt.toLocal();
      final compareDate = DateTime(localDate.year, localDate.month, localDate.day);
      
      String key;
      if (compareDate == today) {
        key = "HOY";
      } else if (compareDate == yesterday) {
        key = "AYER";
      } else {
        final weekdays = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
        final months = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
        key = "${weekdays[localDate.weekday % 7]}, ${localDate.day} ${months[localDate.month - 1]}".toUpperCase();
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(entry);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = _groupEntriesByDate();
    final dominantEmotion = _calculateDominantEmotion();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // 1. Buscador Funcional Estilizado
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Buscar en tu diario...",
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Color(0x3314B8A6), offset: Offset(0, 10), blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("TU SEMANA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0FDFA), letterSpacing: 0.6)),
              const SizedBox(height: 8),
              Text("${entries.length} registros totales", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16), // Espacio controlado adaptativo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: Color(0xFFF0FDFA), size: 16),
                    const SizedBox(width: 8),
                    Text("Principal: $dominantEmotion", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),

        ...groupedEntries.keys.map((dateSection) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  dateSection, 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 0.55)
                ),
              ),
              ...groupedEntries[dateSection]!.map((entry) => _EntryCard(entry: entry)),
            ],
          );
        }),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalDto entry;

  const _EntryCard({required this.entry});

  Color _getEmotionColor() {
    switch (entry.emotionName.toLowerCase()) {
      case 'ansiedad': return const Color(0xFFF59E0B);
      case 'calma': return const Color(0xFF14B8A6);
      case 'enojo': return const Color(0xFFEF4444);
      case 'tristeza': return const Color(0xFF3B82F6);
      default: return const Color(0xFF94A3B8);
    }
  }

  IconData _getEmotionIcon() {
    switch (entry.emotionName.toLowerCase()) {
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
    final Color mainColor = _getEmotionColor();
    final Color lightColor = mainColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), offset: Offset(0, 2), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: lightColor, shape: BoxShape.circle),
                child: Icon(_getEmotionIcon(), color: mainColor, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: lightColor, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  entry.emotionName.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: mainColor, letterSpacing: 0.25),
                ),
              ),
              const Spacer(),
              Text(_formatTime(entry.createdAt), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
              boxShadow: const [BoxShadow(color: Color(0x3314B8A6), blurRadius: 20)],
            ),
            child: const Icon(Icons.eco_outlined, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 24),
          const Text("Tu lienzo en blanco", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHeader)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text("Aún no hay registros hoy. Tómate un momento para escribir cómo te sientes. Tu mente te lo agradecerá.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
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