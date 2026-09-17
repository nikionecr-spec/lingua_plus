import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/core/theme/app_typography.dart';
import 'package:lingua_plus/data/models/word_entry.dart';
import 'package:lingua_plus/features/learning/learning_providers.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// One quiz question: a target row plus 4 shuffled option rows.
class QuizQuestion {
  QuizQuestion({required this.row, required this.options});

  final WordRow row;
  final List<WordRow> options;
}

enum _QuizPhase { loading, active, done, error }

/// Multiple-choice vocabulary quiz (4 options per question).
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  _QuizPhase _phase = _QuizPhase.loading;
  List<QuizQuestion> _questions = const [];
  int _qIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  int _totalXp = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_startQuiz);
  }

  /// Builds a fresh 10-question set ONCE per round.
  Future<void> _startQuiz() async {
    setState(() {
      _phase = _QuizPhase.loading;
      _questions = const [];
      _qIndex = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _totalXp = 0;
    });

    final pool = await ref.read(learningDsProvider).quizPool(limit: 10);
    if (!mounted) return;
    if (pool.length < 4) {
      setState(() => _phase = _QuizPhase.error);
      return;
    }

    final questions = <QuizQuestion>[];
    for (final row in pool) {
      final distractors = pool.where((r) => r.id != row.id).toList()
        ..shuffle();
      questions.add(
        QuizQuestion(
          row: row,
          options: ([row, ...distractors.take(3)]..shuffle()),
        ),
      );
    }
    setState(() {
      _questions = questions;
      _phase = _QuizPhase.active;
    });
  }

  Future<void> _pick(int optionIndex) async {
    if (_answered) return;
    final q = _questions[_qIndex];
    final correct = q.options[optionIndex].id == q.row.id;
    setState(() {
      _answered = true;
      _selected = optionIndex;
      if (correct) _score += 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_qIndex >= _questions.length - 1) {
      await _finish();
    } else {
      setState(() {
        _qIndex += 1;
        _answered = false;
        _selected = null;
      });
    }
  }

  Future<void> _finish() async {
    final xp = _score * 15;
    await ref.read(learningDsProvider).addXp(xp);
    if (!mounted) return;
    setState(() {
      _totalXp = xp;
      _phase = _QuizPhase.done;
    });
    ref.invalidate(statsProvider);
  }

  String _faLabel(WordRow row) {
    for (final m in row.meanings) {
      if (m.definitions.isNotEmpty) return m.definitions.first;
    }
    return '—';
  }

  String get _resultMessage {
    final total = _questions.isEmpty ? 1 : _questions.length;
    final ratio = _score / total;
    if (ratio >= 0.8) return 'عالی بود! 🏆';
    if (ratio >= 0.5) return 'خوب بود! 👍';
    return 'تمرین بیشتر لازمه 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: switch (_phase) {
          _QuizPhase.loading =>
            const Center(child: CircularProgressIndicator()),
          _QuizPhase.error => const EmptyState(
              icon: Icons.error_outline_rounded,
              title: AppStrings.errorGeneric,
              subtitle: 'واژه‌های کافی برای ساخت آزمون پیدا نشد.',
            ),
          _QuizPhase.active => _questionView(context),
          _QuizPhase.done => _resultView(context),
        },
      ),
    );
  }

  Widget _questionView(BuildContext context) {
    final q = _questions[_qIndex];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(Routes.learning),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: GradientProgressBar(
                      value: (_qIndex + 1) / _questions.length,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  En(
                    '${_qIndex + 1} / ${_questions.length}',
                    style: AppTypography.en(
                      fontSize: 12.5,
                      color: AppColors.mutedDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'معنی کدام واژه درست است؟',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.md),
              En(
                q.row.display.isEmpty ? q.row.word : q.row.display,
                style: AppTypography.en(
                  fontSize: 28,
                  weight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              0,
              AppDimensions.lg,
              AppDimensions.xl,
            ),
            itemCount: q.options.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, i) => _optionCard(context, q, i),
          ),
        ),
      ],
    );
  }

  Widget _optionCard(BuildContext context, QuizQuestion q, int i) {
    final option = q.options[i];
    final isCorrect = option.id == q.row.id;
    final selected = _selected == i;
    Color? border;
    IconData? trailing;
    Color trailingColor = Colors.transparent;
    if (_answered) {
      if (isCorrect) {
        border = AppColors.success;
        trailing = Icons.check_circle_rounded;
        trailingColor = AppColors.success;
      } else if (selected) {
        border = AppColors.danger;
        trailing = Icons.cancel_rounded;
        trailingColor = AppColors.danger;
      }
    }
    return GlassCard(
      onTap: _answered ? null : () => _pick(i),
      borderColor: border,
      child: Row(
        children: [
          Expanded(
            child: Text(
              _faLabel(option),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (trailing != null)
            Icon(trailing, color: trailingColor, size: 22),
        ],
      ),
    );
  }

  Widget _resultView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            En(
              '$_score / ${_questions.length}',
              style: AppTypography.en(
                fontSize: 46,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              _resultMessage,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              '${AppStrings.learningXpGained}: +$_totalXp',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.xl),
            GradientButton(
              label: AppStrings.learningQuizAgain,
              icon: Icons.refresh_rounded,
              onPressed: _startQuiz,
            ),
            const SizedBox(height: AppDimensions.sm),
            TextButton(
              onPressed: () => context.go(Routes.learning),
              child: const Text(AppStrings.back),
            ),
          ],
        ),
      ),
    );
  }
}
