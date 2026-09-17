import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/word_entity.dart';

/// Forces LEFT-TO-RAY direction + Poppins font for English content.
/// ALWAYS wrap English text (words, IPA, sentences) in this widget.
class En extends StatelessWidget {
  const En(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        text,
        textAlign: textAlign,
        style: style ?? AppTypography.en(),
        softWrap: true,
      ),
    );
  }
}

/// Soft rounded card with theme-aware fill + hairline border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ??
                (isDark ? AppColors.cardDark : AppColors.cardLight))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.rMd),
        border: Border.all(
          color: borderColor ??
              (isDark ? AppColors.strokeDark : AppColors.strokeLight),
        ),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.rMd),
        child: card,
      ),
    );
  }
}

/// Primary CTA button with brand gradient.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? const LinearGradient(colors: [Colors.grey, Colors.grey])
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.buttonHeight / 2),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(
            expanded ? double.infinity : 0,
            AppDimensions.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.buttonHeight / 2),
          ),
        ),
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.faFamily,
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// CEFR level chip (A1..C2) with its fixed color.
class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.level, this.compact = false});

  final String level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (level.isEmpty) return const SizedBox.shrink();
    final color = AppColors.levelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: En(
        level,
        style: AppTypography.en(
          fontSize: compact ? 10.5 : 11.5,
          weight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Part-of-speech chip with Persian label.
class PosChip extends StatelessWidget {
  const PosChip({super.key, required this.pos, this.compact = false});

  final String pos;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.posColor(pos);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppColors.posLabel(pos),
        style: TextStyle(
          fontFamily: AppTypography.faFamily,
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Section header with optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Friendly empty-state block.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.rLg),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact stat tile (XP, streak, learned count…).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// IPA pronunciation row (US/UK) with a speaker button.
class IpaRow extends StatelessWidget {
  const IpaRow({
    super.key,
    required this.label,
    required this.ipa,
    required this.onSpeak,
  });

  final String label;
  final String ipa;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    if (ipa.isEmpty) return const SizedBox.shrink();
    return GlassCard(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: En(
              ipa,
              style: AppTypography.en(
                fontSize: 15,
                weight: FontWeight.w500,
                color: AppColors.info,
              ),
            ),
          ),
          IconButton(
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            color: AppColors.primary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Reusable dictionary result row (search list / favorites).
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onStar,
  });

  final WordEntity entity;
  final VoidCallback onTap;
  final VoidCallback onStar;

  @override
  Widget build(BuildContext context) {
    final firstFa = entity.meanings.isEmpty
        ? ''
        : entity.meanings.first.definitions.take(2).join('، ');
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: En(
                        entity.display,
                        style: AppTypography.en(
                          fontSize: 16.5,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PosChip(pos: entity.pos, compact: true),
                    const SizedBox(width: 6),
                    LevelChip(level: entity.level, compact: true),
                  ],
                ),
                if (firstFa.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    firstFa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onStar,
            icon: Icon(
              entity.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: entity.isFavorite
                  ? AppColors.warning
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Onboarding page dots.
class PageDot extends StatelessWidget {
  const PageDot({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 22 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : AppColors.mutedDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Thin progress bar with brand gradient.
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 8,
  });

  final double value; // 0..1
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.night2
                : AppColors.strokeLight,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
