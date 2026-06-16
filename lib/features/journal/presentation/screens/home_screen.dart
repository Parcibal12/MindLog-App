import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'package:mindlog_app/core/utils/date_formatter.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../providers/home_controller.dart';
import '../../data/models/journal_dto.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
                        DateFormatter.formatShortDate(DateTime.now()),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 0.55),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Hola, Daniel",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHeader),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: Container(
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
    );
  }
}

// Convertido a Stateful para manejar el TextEditingController y evitar el bug de onChanged
class _FilledState extends ConsumerStatefulWidget {
  final List<JournalDto> entries;

  const _FilledState({required this.entries});

  @override
  ConsumerState<_FilledState> createState() => _FilledStateState();
}

class _FilledStateState extends ConsumerState<_FilledState> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Escuchamos el controlador y actualizamos el Provider dinámicamente
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _calculateDominantEmotion(List<JournalDto> listToAnalyze) {
    if (listToAnalyze.isEmpty) return "Ninguna";
    final Map<String, int> frequencyMap = {};
    for (var entry in listToAnalyze) {
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

  Map<String, List<JournalDto>> _groupEntriesByDate(List<JournalDto> listToGroup) {
    final Map<String, List<JournalDto>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var entry in listToGroup) {
      final localDate = entry.createdAt.toLocal();
      final compareDate = DateTime(localDate.year, localDate.month, localDate.day);
      
      String key;
      if (compareDate == today) {
        key = "HOY";
      } else if (compareDate == yesterday) {
        key = "AYER";
      } else {
        key = DateFormatter.formatShortDate(localDate);
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
    final searchQuery = ref.watch(searchQueryProvider);
    
    final filteredEntries = widget.entries.where((entry) {
      final query = searchQuery.toLowerCase();
      return entry.content.toLowerCase().contains(query) || 
             entry.emotionName.toLowerCase().contains(query);
    }).toList();

    final groupedEntries = _groupEntriesByDate(filteredEntries);
    final dominantEmotion = _calculateDominantEmotion(widget.entries);
    final palette = EmotionThemeMapper.getPalette(dominantEmotion);
    final streakAsync = ref.watch(currentStreakProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: MindLogTextField(
            hintText: "Buscar en tu diario...",
            prefixIcon: Icons.search,
            controller: _searchController, // <-- Usamos el controlador que tu app sí reconoce
          ),
        ),

        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: palette.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: palette.shadow, offset: const Offset(0, 10), blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("TU SEMANA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0FDFA), letterSpacing: 0.6)),
              const SizedBox(height: 8),
              Text("${widget.entries.length} registros totales", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16), 
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

        streakAsync.when(
          data: (streak) => MindLogCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak > 0 ? "¡Racha de $streak días!" : "Inicia tu racha hoy",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeader),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        streak > 0 ? "Sigue escribiendo para no perderla." : "Registra cómo te sientes.",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 8),

        if (filteredEntries.isEmpty && searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No se encontraron resultados para "$searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSubtitle),
              ),
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

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmotionThemeMapper.getPalette(entry.emotionName);

    return MindLogCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: palette.lightBackground, shape: BoxShape.circle),
                child: Icon(palette.icon, color: palette.main, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: palette.lightBackground, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  entry.emotionName.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: palette.main, letterSpacing: 0.25),
                ),
              ),
              const Spacer(),
              Text(_formatTime(entry.createdAt), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: const TextStyle(fontSize: 14, color: const Color(0xFF475569), height: 1.5),
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