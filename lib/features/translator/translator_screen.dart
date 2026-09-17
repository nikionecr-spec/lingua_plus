import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/ui_kit.dart';
import 'translator_providers.dart';

/// Online translator: auto/fa/en source, fa/en target, STT mic input,
/// TTS playback, copy & share. Powered by free key-less APIs.
class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({super.key});

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _listening = false;

  @override
  void dispose() {
    _controller.dispose();
    if (_listening) {
      ref.read(speechProvider).stopListening();
    }
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final speech = ref.read(speechProvider);
    if (_listening) {
      await speech.stopListening();
      setState(() => _listening = false);
      return;
    }
    final src = ref.read(sourceLangProvider);
    final locale = (src == 'fa') ? 'fa-IR' : 'en-US';
    final ok = await speech.listen(
      localeId: locale,
      onResult: (text) {
        ref.read(sourceTextProvider.notifier).state = text;
        setState(() => _controller.text = text);
      },
    );
    setState(() => _listening = ok);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorGeneric)),
      );
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.copied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trState = ref.watch(translatorStateProvider);
    final sourceLang = ref.watch(sourceLangProvider);
    final targetLang = ref.watch(targetLangProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: pagePadding() +
            const EdgeInsets.only(top: AppDimensions.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.translatorTitle,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),

            // ── Language selector ──────────────────────────────────────
            _LangSelector(
              sourceLang: sourceLang,
              targetLang: targetLang,
            ),
            const SizedBox(height: AppDimensions.lg),

            // ── Source card ────────────────────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      minLines: 3,
                      decoration: const InputDecoration(
                        hintText: AppStrings.translatorInputHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      style: AppTypography.en(fontSize: 16, height: 1.6),
                      onChanged: (v) =>
                          ref.read(sourceTextProvider.notifier).state = v,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleMic,
                        icon: Icon(
                          _listening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          color: _listening
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                        tooltip: AppStrings.translatorMicHint,
                      ),
                      const Spacer(),
                      Text(
                        '${_controller.text.length}',
                        style: textTheme.labelSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(sourceTextProvider.notifier).state = '';
                          setState(() => _controller.clear());
                          ref.read(translatorStateProvider.notifier).reset();
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (_listening)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.translatorListening,
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ── Translate button ───────────────────────────────────────
            GradientButton(
              label: AppStrings.translatorTranslate,
              icon: Icons.translate_rounded,
              onPressed: () =>
                  ref.read(translatorStateProvider.notifier).translateNow(),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ── Target card ────────────────────────────────────────────
            GlassCard(
              child: _buildTarget(context, trState),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTarget(BuildContext context, TranslationUiState trState) {
    final textTheme = Theme.of(context).textTheme;

    switch (trState.status) {
      case 'loading':
        return const Padding(
          padding: EdgeInsets.all(AppDimensions.xl),
          child: Center(child: CircularProgressIndicator()),
        );

      case 'success':
        final result = trState.result!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.toLang == 'en')
              En(
                result.output,
                style: AppTypography.en(
                  fontSize: 17,
                  height: 1.7,
                  weight: FontWeight.w500,
                ),
              )
            else
              SelectableText(
                result.output,
                style: textTheme.bodyLarge,
              ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                IconButton(
                  onPressed: () => ref.read(speechProvider).speak(
                        result.output,
                        lang: result.toLang == 'fa' ? 'fa-IR' : 'en-US',
                      ),
                  icon: const Icon(Icons.volume_up_rounded),
                  color: AppColors.primary,
                  tooltip: AppStrings.pronunciationUs,
                ),
                IconButton(
                  onPressed: () => _copy(result.output),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  color: AppColors.info,
                  tooltip: AppStrings.copy,
                ),
                IconButton(
                  onPressed: () => Share.share(result.output),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  color: AppColors.accent,
                  tooltip: AppStrings.share,
                ),
                const Spacer(),
                En(
                  result.provider,
                  style: AppTypography.en(
                    fontSize: 11,
                    weight: FontWeight.w500,
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ],
        );

      case 'error':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.danger, size: 32),
              const SizedBox(height: AppDimensions.sm),
              Text(
                trState.error ?? AppStrings.translatorError,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        );

      default: // idle
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
          child: Column(
            children: [
              const Icon(Icons.translate_rounded,
                  color: AppColors.mutedDark, size: 32),
              const SizedBox(height: AppDimensions.sm),
              Text(
                AppStrings.translatorOutputHint,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        );
    }
  }
}

/// Source/target language chips + swap button.
class _LangSelector extends ConsumerWidget {
  const _LangSelector({
    required this.sourceLang,
    required this.targetLang,
  });

  final String? sourceLang;
  final String targetLang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _langChips(
            context,
            ref,
            isSource: true,
            current: sourceLang,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        _SwapButton(),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _langChips(
            context,
            ref,
            isSource: false,
            current: targetLang,
          ),
        ),
      ],
    );
  }

  Widget _langChips(
    BuildContext context,
    WidgetRef ref, {
    required bool isSource,
    required String? current,
  }) {
    final entries = <(String?, String)>[
      if (isSource) (null, AppStrings.translatorAuto),
      ('fa', AppStrings.translatorFa),
      ('en', AppStrings.translatorEn),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (value, label) in entries)
          ChoiceChip(
            label: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: current == value
                        ? Colors.white
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            selected: current == value,
            selectedColor: AppColors.primary,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
            onSelected: (_) {
              if (isSource) {
                ref.read(sourceLangProvider.notifier).state = value;
              } else {
                ref.read(targetLangProvider.notifier).state = value!;
              }
              ref.read(translatorStateProvider.notifier).reset();
            },
          ),
      ],
    );
  }
}

class _SwapButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => swapLanguages(ref),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.swap_horiz_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
