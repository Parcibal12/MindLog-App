import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'package:mindlog_app/core/utils/date_formatter.dart';
import '../providers/journal_draft_provider.dart';
import '../providers/editor_controller.dart';
import 'labeled_screen.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    final aiResult = await ref.read(editorControllerProvider.notifier).analyze(text);

    if (mounted && aiResult != null) {
      ref.read(journalContentDraftProvider.notifier).state = text;
      ref.read(aiFeedbackProvider.notifier).state = aiResult["feedback"]!;
      ref.read(aiPatternProvider.notifier).state = aiResult["pattern"]!;
      ref.read(draftEmotionIdProvider.notifier).state = aiResult["emotionId"];
      ref.read(draftIntensityProvider.notifier).state = aiResult["intensity"];
      ref.read(draftContextTagsProvider.notifier).state = aiResult["contextTagIds"];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LabeledScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al analizar el texto"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSubtitle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    children: [
                      const Text("HOY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
                      Text(
                        DateFormatter.formatFullDate(DateTime.now()), 
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textNumber)
                      ),
                    ],
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    const Text("¿Qué hay en tu mente\nhoy?", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textHeader, height: 1.25)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF475569), height: 1.6),
                        decoration: const InputDecoration(
                          hintText: "Escribe libremente lo que sientes...",
                          hintStyle: TextStyle(color: AppColors.textSubtitle),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: editorState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGreen), 
                      )
                    : MindLogButton(
                        text: "Siguiente",
                        onPressed: _onNextPressed,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}