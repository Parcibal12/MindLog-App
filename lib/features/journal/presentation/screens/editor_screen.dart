import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindlog_app/core/theme/app_colors.dart';
import '../providers/journal_draft_provider.dart';
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

  void _onNextPressed() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(journalContentDraftProvider.notifier).state = text;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LabeledScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Column(
                    children: [
                      Text("HOY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1)),
                      Text("10 de Diciembre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textNumber)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    ),
                    child: const Text("Siguiente", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
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
          ],
        ),
      ),
    );
  }
}