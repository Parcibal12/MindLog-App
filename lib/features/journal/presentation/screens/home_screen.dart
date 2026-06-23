import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'package:mindlog_app/core/utils/date_formatter.dart';
import '../../../../core/providers/network_provider.dart';
import '../../data/models/journal_dto.dart';
import '../providers/home_controller.dart';
import '../providers/sync_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineModeProvider);
    final entriesAsyncValue = ref.watch(journalEntriesProvider);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isOffline ? 40 : 0,
              width: double.infinity,
              color: AppColors.warningMode,
              child: isOffline
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Modo sin conexión - Viendo datos locales",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.55),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Hola, Daniel",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/profile');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkAvatarBackground : AppColors.avatarBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.primaryDark : AppColors.avatarBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text("D", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.secondaryGreen : AppColors.primaryDark)),
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
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(entry);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredEntries = widget.entries.where((entry) {
      final query = searchQuery.toLowerCase();
      return entry.content.toLowerCase().contains(query) || entry.emotionName.toLowerCase().contains(query);
    }).toList();

    final groupedEntries = _groupEntriesByDate(filteredEntries);
    final dominantEmotion = _calculateDominantEmotion(widget.entries);
    final palette = EmotionThemeMapper.getPalette(dominantEmotion);
    final streakAsync = ref.watch(currentStreakProvider);

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        await ref.read(syncServiceProvider).runSilentSync();
        ref.invalidate(journalEntriesProvider);
        ref.invalidate(currentStreakProvider);
        try { 
          await ref.read(journalEntriesProvider.future); 
          if (ref.read(isOfflineModeProvider) && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Aún sin red. El diario sigue guardado en tu bóveda."), 
                backgroundColor: AppColors.warningMode,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: MindLogTextField(
              hintText: "Buscar en tu diario...",
              prefixIcon: Icons.search,
              controller: _searchController,
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
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkStreakBackground : AppColors.streakBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: AppColors.streakIcon, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          streak > 0 ? "¡Racha de $streak días!" : "Inicia tu racha hoy",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          streak > 0 ? "Sigue escribiendo para no perderla." : "Registra cómo te sientes.",
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
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
                  style: TextStyle(color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 0.55)
                  ),
                ),
                ...groupedEntries[dateSection]!.map((entry) => _EntryCard(entry: entry)),
              ],
            );
          }),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Text(_formatTime(entry.createdAt), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        await ref.read(syncServiceProvider).runSilentSync();
        ref.invalidate(journalEntriesProvider);
        ref.invalidate(currentStreakProvider);
        try { 
          await ref.read(journalEntriesProvider.future); 
          if (ref.read(isOfflineModeProvider) && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Aún sin red. El diario sigue guardado en tu bóveda."), 
                backgroundColor: AppColors.warningMode,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.avatarBorder,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppColors.primaryDark : Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Color(0x3314B8A6), blurRadius: 20)],
                ),
                child: const Icon(Icons.eco_outlined, color: AppColors.primaryGreen, size: 40),
              ),
              const SizedBox(height: 24),
              Text("Tu lienzo en blanco", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text("Aún no hay registros hoy. Tómate un momento para escribir cómo te sientes. Tu mente te lo agradecerá.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}