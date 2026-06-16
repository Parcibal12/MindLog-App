import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';
import 'package:mindlog_app/core/theme/emotion_theme_mapper.dart';
import '../providers/journal_draft_provider.dart';
import '../providers/editor_controller.dart';
import '../providers/home_controller.dart';
import '../../data/models/metadata_dto.dart'; 

class LabeledScreen extends ConsumerStatefulWidget {
  const LabeledScreen({super.key});

  @override
  ConsumerState<LabeledScreen> createState() => _LabeledScreenState();
}

class _LabeledScreenState extends ConsumerState<LabeledScreen> {
  int? _selectedEmotionId; 
  EmotionDto? _selectedEmotionData;
  double _intensity = 8.0;
  final List<int> _selectedContextIds = []; 

  void _toggleContext(int tagId) {
    setState(() {
      if (_selectedContextIds.contains(tagId)) {
        _selectedContextIds.remove(tagId);
      } else {
        _selectedContextIds.add(tagId);
      }
    });
  }

  void _handleSave(String content) async {
    final currentEmotion = _selectedEmotionData;
    if (currentEmotion == null) return;

    final feedback = ref.read(aiFeedbackProvider);
    final pattern = ref.read(aiPatternProvider);

    final success = await ref.read(editorControllerProvider.notifier).saveEntry(
      content: content,
      emotionId: currentEmotion.id,
      emotionName: currentEmotion.name,
      intensity: _intensity.toInt(),
      contextTagIds: _selectedContextIds, 
      aiFeedback: feedback,
      aiPattern: pattern,
    );

    if (mounted) {
      if (success) {
        ref.invalidate(journalEntriesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diario guardado con éxito"), backgroundColor: AppColors.primaryGreen),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar en el servidor"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalContent = ref.watch(journalContentDraftProvider);
    final isLoading = ref.watch(editorControllerProvider).isLoading;
    final aiFeedback = ref.watch(aiFeedbackProvider);
    
    final emotionsAsync = ref.watch(emotionsProvider);
    final tagsAsync = ref.watch(contextTagsProvider);
    
    final selectedPalette = EmotionThemeMapper.getPalette(_selectedEmotionData?.name ?? 'Calma');
    final bool canSave = _selectedEmotionId != null && !isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            top: 96,
            bottom: 96,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 24, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("¿Cómo te sentiste?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(height: 4),
                        Text("Selecciona la emoción predominante", style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: emotionsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                      error: (err, st) => Text("Error: $err", style: const TextStyle(color: Colors.red)),
                      data: (emotions) {
                        return Row(
                          children: emotions.map((em) {
                            final isSelected = _selectedEmotionId == em.id;
                            final palette = EmotionThemeMapper.getPalette(em.name); 
                            
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedEmotionId = em.id;
                                  _selectedEmotionData = em;
                                }),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: isSelected ? palette.lightBackground : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? palette.main : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(palette.icon, size: 32, color: isSelected ? palette.main : const Color(0xFF94A3B8)),
                                          const SizedBox(height: 8),
                                          Text(
                                            em.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? palette.main : const Color(0xFF94A3B8),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(color: palette.main, shape: BoxShape.circle),
                                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text("Intensidad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const Spacer(),
                            Text(_intensity.toInt().toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: selectedPalette.main)),
                            const Text("/10", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Leve", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                            Text("Moderada", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                            Text("Severa", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: selectedPalette.main,
                            inactiveTrackColor: const Color(0xFFE2E8F0),
                            thumbColor: Colors.white,
                            trackHeight: 8,
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            value: _intensity,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (val) => setState(() => _intensity = val),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("¿En qué contexto?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        const Text("Puedes seleccionar más de uno", style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 12),
                        
                        tagsAsync.when(
                          loading: () => const CircularProgressIndicator(color: AppColors.primaryGreen),
                          error: (err, st) => const Text("Error", style: TextStyle(color: Colors.red)),
                          data: (tags) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tags.map((tag) {
                                final isSelected = _selectedContextIds.contains(tag.id);
                                return GestureDetector(
                                  onTap: () => _toggleContext(tag.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryGreen : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      tag.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedPalette.lightBackground, 
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selectedPalette.main.withValues(alpha: 0.2)),
                      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bolt, color: selectedPalette.main, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ESPEJO COGNITIVO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selectedPalette.main, letterSpacing: 0.6)),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6, fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(text: '"$aiFeedback"'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 96,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text("Detalles de entrada", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 96,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                boxShadow: [BoxShadow(color: Color(0x07000000), offset: Offset(0, -10), blurRadius: 10)],
              ),
              child: ElevatedButton(
                onPressed: canSave ? () => _handleSave(journalContent) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSave ? AppColors.primaryGreen : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: canSave ? 4 : 0,
                  shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text("Guardar Entrada", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}