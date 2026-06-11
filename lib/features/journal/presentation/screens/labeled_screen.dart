import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';
import '../providers/journal_draft_provider.dart';
import '../providers/editor_controller.dart';
import '../providers/home_controller.dart';

class EmotionItem {
  final int id;
  final String label;
  final IconData icon;
  final Color color;

  EmotionItem(this.id, this.label, this.icon, this.color);
}

final List<EmotionItem> _emotions = [
  EmotionItem(1, "Calma", Icons.sentiment_satisfied_alt, const Color(0xFF14B8A6)), // Teal
  EmotionItem(2, "Ansiedad", Icons.sentiment_dissatisfied, const Color(0xFFF59E0B)), // Naranja
  EmotionItem(3, "Enojo", Icons.sentiment_very_dissatisfied, const Color(0xFFEF4444)), // Rojo
  EmotionItem(4, "Tristeza", Icons.sentiment_neutral, const Color(0xFF3B82F6)), // Azul
];

final List<String> _contextOptions = ["Universidad", "Familia", "Trabajo", "Pareja", "Salud"];

class LabeledScreen extends ConsumerStatefulWidget {
  const LabeledScreen({super.key});

  @override
  ConsumerState<LabeledScreen> createState() => _LabeledScreenState();
}

class _LabeledScreenState extends ConsumerState<LabeledScreen> {
  int _selectedEmotionId = 2;
  double _intensity = 8.0;
  final List<String> _selectedContexts = ["Universidad"];

  void _toggleContext(String ctx) {
    setState(() {
      if (_selectedContexts.contains(ctx)) {
        _selectedContexts.remove(ctx);
      } else {
        _selectedContexts.add(ctx);
      }
    });
  }

  void _handleSave(String content) async {
    final selectedEmotion = _emotions.firstWhere((e) => e.id == _selectedEmotionId);
    
    final contextIds = _selectedContexts.map((c) => _contextOptions.indexOf(c) + 1).toList();

    final success = await ref.read(editorControllerProvider.notifier).saveEntry(
      content: content,
      emotionId: selectedEmotion.id,
      emotionName: selectedEmotion.label,
      intensity: _intensity.toInt(),
      contextTagIds: contextIds,
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
    final selectedEmotionData = _emotions.firstWhere((e) => e.id == _selectedEmotionId);

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
                    child: Row(
                      children: _emotions.map((em) {
                        final isSelected = _selectedEmotionId == em.id;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedEmotionId = em.id),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 85,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? em.color : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: const [BoxShadow(color: Color(0x0C000000), offset: Offset(0, 1), blurRadius: 1)],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(em.icon, size: 32, color: isSelected ? em.color : const Color(0xFF94A3B8)),
                                      const SizedBox(height: 8),
                                      Text(
                                        em.label.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? em.color : const Color(0xFF94A3B8),
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
                                        decoration: BoxDecoration(color: em.color, shape: BoxShape.circle),
                                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                            Text(_intensity.toInt().toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: selectedEmotionData.color)),
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
                            activeTrackColor: selectedEmotionData.color,
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _contextOptions.map((ctx) {
                            final isSelected = _selectedContexts.contains(ctx);
                            return GestureDetector(
                              onTap: () => _toggleContext(ctx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF14B8A6) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  ctx,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF0FDFA), Color(0xFFECFDF5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCCFBF1)),
                      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFF14B8A6), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ESPEJO COGNITIVO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E), letterSpacing: 0.6)),
                              const SizedBox(height: 8),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 14, color: Color(0xCC134E4A), height: 1.6, fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(text: '"Nota de tu diario: Usaste palabras absolutistas como '),
                                    TextSpan(text: 'siempre', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
                                    TextSpan(text: '. Recuerda que un mal evento no define toda tu capacidad."'),
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
                onPressed: isLoading ? null : () => _handleSave(journalContent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0x4D14B8A6),
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