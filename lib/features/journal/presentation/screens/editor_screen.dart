import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindlog_design_system/mindlog_design_system.dart';
import 'package:mindlog_app/core/utils/date_formatter.dart';
import '../providers/journal_draft_provider.dart';
import '../providers/editor_controller.dart';

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

      context.push('/labeled');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al analizar el texto"), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
                    onPressed: () => context.pop(),
                  ),
                  Column(
                    children: [
                      Text("HOY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle, letterSpacing: 1)),
                      Text(
                        DateFormatter.formatFullDate(DateTime.now()), 
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber)
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
                    Text("¿Qué hay en tu mente\nhoy?", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextHeader : AppColors.textHeader, height: 1.25)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 18, color: isDark ? AppColors.darkTextHeader : AppColors.textNumber, height: 1.6),
                        decoration: InputDecoration(
                          hintText: "Escribe libremente lo que sientes...",
                          hintStyle: TextStyle(color: isDark ? AppColors.darkTextSubtitle : AppColors.textSubtitle),
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