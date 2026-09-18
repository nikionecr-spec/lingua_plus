import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lingua+ bespoke icon set — hand-drawn vector painters on a 24×24 grid.
/// Nothing here comes from Material's icon font or emoji: every glyph is
/// drawn with rounded strokes in the app's own design language.
///
/// Painters are top-level functions so every [LpIconData] is a compile-time
/// constant (usable inside `const` widget trees).
class LpIconData {
  const LpIconData(this.painter);

  final void Function(Canvas canvas, Paint stroke) painter;
}

/// Stroke style shared by all painters (drawn on a 24×24 grid, scaled).
Paint _strokePaint(Color color, double strokeWidth) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = strokeWidth
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Fill style for solid accents (e.g. star fill).
Paint _fillPaint(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill;

/// Custom-painted icon widget.
class LpIcon extends StatelessWidget {
  const LpIcon(this.data, {super.key, this.size = 24, this.color});

  final LpIconData data;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effective =
        color ?? Theme.of(context).iconTheme.color ?? Colors.black87;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LpIconPainter(data, effective),
        size: Size.square(size),
      ),
    );
  }
}

class _LpIconPainter extends CustomPainter {
  _LpIconPainter(this.data, this.color);

  final LpIconData data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = _strokePaint(color, 1.9);
    data.painter(canvas, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LpIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.data != data;
}

/// 5-point star polygon path (shared by outline/filled variants).
void _starPath(Path p, double cx, double cy, double r) {
  const points = 5;
  const innerRatio = 0.445;
  for (var i = 0; i < points * 2; i++) {
    final angle = -math.pi / 2 + i * math.pi / points;
    final radius = i.isEven ? r : r * innerRatio;
    final x = cx + radius * math.cos(angle);
    final y = cy + radius * math.sin(angle);
    if (i == 0) {
      p.moveTo(x, y);
    } else {
      p.lineTo(x, y);
    }
  }
  p.close();
}

// ── Painters ──────────────────────────────────────────────────────────────

void _homePaint(Canvas c, Paint p) {
  c.drawRRect(
    RRect.fromRectAndCorners(
      const Rect.fromLTWH(4, 9.5, 16, 11),
      topLeft: const Radius.circular(2.5),
      topRight: const Radius.circular(2.5),
      bottomLeft: const Radius.circular(2.5),
      bottomRight: const Radius.circular(2.5),
    ),
    p,
  );
  final roof = Path()
    ..moveTo(2.8, 10.6)
    ..lineTo(12, 3.2)
    ..lineTo(21.2, 10.6);
  c.drawPath(roof, p);
  final door = RRect.fromRectAndCorners(
    const Rect.fromLTWH(9.8, 14.2, 4.4, 6.3),
    topLeft: const Radius.circular(2.2),
    topRight: const Radius.circular(2.2),
  );
  c.drawRRect(door, p);
}

void _dictionaryPaint(Canvas c, Paint p) {
  final book = Path()
    ..moveTo(12, 6.4)
    ..cubicTo(10.2, 4.9, 7.4, 4.6, 4.4, 4.9)
    ..lineTo(4.4, 17.6)
    ..cubicTo(7.4, 17.3, 10.2, 17.6, 12, 19.1)
    ..cubicTo(13.8, 17.6, 16.6, 17.3, 19.6, 17.6)
    ..lineTo(19.6, 4.9)
    ..cubicTo(16.6, 4.6, 13.8, 4.9, 12, 6.4)
    ..close();
  c.drawPath(book, p);
  c.drawLine(const Offset(12, 6.4), const Offset(12, 19.1), p);
  c.drawCircle(const Offset(15.2, 9.4), 2.05, p);
  c.drawLine(const Offset(16.7, 11.0), const Offset(18.3, 12.6), p);
}

void _libraryPaint(Canvas c, Paint p) {
  c.drawLine(const Offset(4, 4), const Offset(4, 20), p);
  c.drawLine(const Offset(20, 4), const Offset(20, 20), p);
  c.drawLine(const Offset(7.5, 6.5), const Offset(7.5, 17.5), p);
  c.drawLine(const Offset(10.5, 6.5), const Offset(10.5, 17.5), p);
  final tilted = Path()
    ..moveTo(16.9, 6.6)
    ..lineTo(13.7, 17.4);
  c.drawPath(tilted, p);
  c.drawLine(const Offset(16.9, 6.6), const Offset(18.6, 17.0), p);
}

void _translatorPaint(Canvas c, Paint p) {
  final back = RRect.fromRectAndRadius(
    const Rect.fromLTWH(3.2, 3.6, 12.2, 9.6),
    const Radius.circular(3.4),
  );
  c.drawRRect(back, p);
  final front = RRect.fromRectAndRadius(
    const Rect.fromLTWH(9.4, 10.6, 11.4, 9.4),
    const Radius.circular(3.4),
  );
  c.drawRRect(front, p);
  c.drawLine(const Offset(6.1, 7.3), const Offset(9.1, 7.3), p);
  c.drawLine(const Offset(6.1, 9.9), const Offset(7.9, 9.9), p);
  final fill = _fillPaint(p.color);
  c.drawCircle(const Offset(12.9, 15.3), 0.95, fill);
  c.drawCircle(const Offset(15.3, 15.3), 0.95, fill);
}

void _settingsPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 3.1, p);
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    c.drawLine(
      Offset(12 + 6.1 * math.cos(a), 12 + 6.1 * math.sin(a)),
      Offset(12 + 8.2 * math.cos(a), 12 + 8.2 * math.sin(a)),
      p,
    );
  }
}

void _searchPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(11, 11), 6.2, p);
  c.drawLine(const Offset(15.6, 15.6), const Offset(20.2, 20.2), p);
}

void _searchOffPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(11, 11), 6.2, p);
  c.drawLine(const Offset(15.6, 15.6), const Offset(20.2, 20.2), p);
  c.drawLine(
      const Offset(4.2, 4.2), const Offset(17.8, 17.8),
      _strokePaint(p.color, 1.7));
}

void _volumeUpPaint(Canvas c, Paint p) {
  final body = Path()
    ..moveTo(4, 9.6)
    ..lineTo(7.6, 9.6)
    ..lineTo(12.2, 5.6)
    ..lineTo(12.2, 18.4)
    ..lineTo(7.6, 14.4)
    ..lineTo(4, 14.4)
    ..close();
  c.drawPath(body, p);
  c.drawArc(const Rect.fromLTWH(13.6, 8.6, 6.2, 6.8), -0.9, 1.8, false, p);
  c.drawArc(const Rect.fromLTWH(15.8, 6.4, 8.4, 11.2), -0.9, 1.8, false, p);
}

void _volumePaint(Canvas c, Paint p) {
  final body = Path()
    ..moveTo(4.6, 9.8)
    ..lineTo(7.8, 9.8)
    ..lineTo(12, 6.0)
    ..lineTo(12, 18.0)
    ..lineTo(7.8, 14.2)
    ..lineTo(4.6, 14.2)
    ..close();
  c.drawPath(body, p);
  c.drawArc(const Rect.fromLTWH(13.6, 8.8, 6.0, 6.4), -0.85, 1.7, false, p);
}

void _micPaint(Canvas c, Paint p) {
  final capsule = RRect.fromRectAndRadius(
    const Rect.fromLTWH(9.6, 3.4, 4.8, 10.2),
    const Radius.circular(2.4),
  );
  c.drawRRect(capsule, p);
  final cradle = Path()
    ..moveTo(5.8, 11.4)
    ..cubicTo(5.8, 15.1, 8.5, 17.6, 12, 17.6)
    ..cubicTo(15.5, 17.6, 18.2, 15.1, 18.2, 11.4);
  c.drawPath(cradle, p);
  c.drawLine(const Offset(12, 17.6), const Offset(12, 20.8), p);
  c.drawLine(const Offset(9.2, 20.8), const Offset(14.8, 20.8), p);
}

void _swapPaint(Canvas c, Paint p) {
  final top = Path()
    ..moveTo(4.4, 8.6)
    ..lineTo(17.6, 8.6)
    ..lineTo(14.6, 5.6);
  c.drawPath(top, p);
  final bottom = Path()
    ..moveTo(19.6, 15.4)
    ..lineTo(6.4, 15.4)
    ..lineTo(9.4, 18.4);
  c.drawPath(bottom, p);
}

void _starPaint(Canvas c, Paint p) {
  final path = Path();
  _starPath(path, 12, 12.4, 8.4);
  c.drawPath(path, p);
}

void _starFilledPaint(Canvas c, Paint p) {
  final path = Path();
  _starPath(path, 12, 12.4, 8.4);
  c.drawPath(path, _fillPaint(p.color));
}

void _bookmarkPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(6.6, 4.4)
    ..lineTo(17.4, 4.4)
    ..lineTo(17.4, 20)
    ..lineTo(12, 15.2)
    ..lineTo(6.6, 20)
    ..close();
  c.drawPath(path, p);
}

void _bookmarkFilledPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(6.6, 4.4)
    ..lineTo(17.4, 4.4)
    ..lineTo(17.4, 20)
    ..lineTo(12, 15.2)
    ..lineTo(6.6, 20)
    ..close();
  c.drawPath(path, _fillPaint(p.color));
}

void _sharePaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(6.4, 12), 2.5, p);
  c.drawCircle(const Offset(17.6, 5.8), 2.5, p);
  c.drawCircle(const Offset(17.6, 18.2), 2.5, p);
  c.drawLine(const Offset(8.6, 10.8), const Offset(15.4, 7.1), p);
  c.drawLine(const Offset(8.6, 13.2), const Offset(15.4, 16.9), p);
}

void _trashPaint(Canvas c, Paint p) {
  c.drawLine(const Offset(4.6, 6.4), const Offset(19.4, 6.4), p);
  final bin = RRect.fromRectAndCorners(
    const Rect.fromLTWH(6.4, 6.4, 11.2, 13.6),
    bottomLeft: const Radius.circular(2.6),
    bottomRight: const Radius.circular(2.6),
  );
  c.drawRRect(bin, p);
  c.drawLine(const Offset(10.1, 9.8), const Offset(10.1, 16.6), p);
  c.drawLine(const Offset(13.9, 9.8), const Offset(13.9, 16.6), p);
}

void _closePaint(Canvas c, Paint p) {
  c.drawLine(const Offset(6, 6), const Offset(18, 18), p);
  c.drawLine(const Offset(18, 6), const Offset(6, 18), p);
}

void _checkPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(4.6, 12.6)
    ..lineTo(9.6, 17.6)
    ..lineTo(19.4, 6.6);
  c.drawPath(path, p);
}

void _copyPaint(Canvas c, Paint p) {
  final back = RRect.fromRectAndRadius(
    const Rect.fromLTWH(8.4, 3.6, 11, 12.4),
    const Radius.circular(2.4),
  );
  c.drawRRect(back, p);
  final front = RRect.fromRectAndRadius(
    const Rect.fromLTWH(4.6, 8, 11, 12.4),
    const Radius.circular(2.4),
  );
  c.drawRRect(front, p);
}

void _backspacePaint(Canvas c, Paint p) {
  final shape = Path()
    ..moveTo(8.6, 5.6)
    ..lineTo(19.2, 5.6)
    ..cubicTo(20.0, 5.6, 20.6, 6.3, 20.6, 7.0)
    ..lineTo(20.6, 17.0)
    ..cubicTo(20.6, 17.8, 20.0, 18.4, 19.2, 18.4)
    ..lineTo(8.6, 18.4)
    ..lineTo(3.4, 12.0)
    ..close();
  c.drawPath(shape, p);
  c.drawLine(const Offset(11.6, 9.4), const Offset(16.4, 14.6), p);
  c.drawLine(const Offset(16.4, 9.4), const Offset(11.6, 14.6), p);
}

void _chevronLeftPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(14.6, 5.2)
    ..lineTo(8, 12)
    ..lineTo(14.6, 18.8);
  c.drawPath(path, p);
}

void _chevronRightPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(9.4, 5.2)
    ..lineTo(16, 12)
    ..lineTo(9.4, 18.8);
  c.drawPath(path, p);
}

void _moonPaint(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(19.6, 14.2)
    ..cubicTo(17.0, 15.4, 13.9, 14.4, 12.4, 11.9)
    ..cubicTo(10.9, 9.4, 11.6, 6.2, 13.7, 4.4)
    ..cubicTo(9.5, 4.6, 5.6, 8.0, 5.6, 12.4)
    ..cubicTo(5.6, 16.9, 9.2, 20.4, 13.6, 20.4)
    ..cubicTo(16.4, 20.4, 18.7, 18.5, 19.6, 14.2)
    ..close();
  c.drawPath(path, p);
}

void _sunPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 4.1, p);
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    c.drawLine(
      Offset(12 + 6.3 * math.cos(a), 12 + 6.3 * math.sin(a)),
      Offset(12 + 8.6 * math.cos(a), 12 + 8.6 * math.sin(a)),
      p,
    );
  }
}

void _autoThemePaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 8, p);
  final half = Path()
    ..arcTo(
      Rect.fromCircle(center: const Offset(12, 12), radius: 8),
      -math.pi / 2,
      math.pi,
      false,
    )
    ..close();
  c.drawPath(half, _fillPaint(p.color));
}

void _sparklePaint(Canvas c, Paint p) {
  final main = Path()
    ..moveTo(12, 3.4)
    ..cubicTo(12.8, 8.0, 14.2, 9.6, 19.2, 10.6)
    ..cubicTo(14.2, 11.6, 12.8, 13.2, 12, 17.8)
    ..cubicTo(11.2, 13.2, 9.8, 11.6, 4.8, 10.6)
    ..cubicTo(9.8, 9.6, 11.2, 8.0, 12, 3.4)
    ..close();
  c.drawPath(main, p);
  final small = Path()
    ..moveTo(18.2, 15.4)
    ..cubicTo(18.5, 17.2, 19.1, 17.8, 20.9, 18.2)
    ..cubicTo(19.1, 18.6, 18.5, 19.2, 18.2, 21)
    ..cubicTo(17.9, 19.2, 17.3, 18.6, 15.5, 18.2)
    ..cubicTo(17.3, 17.8, 17.9, 17.2, 18.2, 15.4)
    ..close();
  c.drawPath(small, p);
}

void _globePaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 8.2, p);
  c.drawOval(const Rect.fromLTWH(7.4, 3.8, 9.2, 16.4), p);
  c.drawLine(const Offset(3.8, 12), const Offset(20.2, 12), p);
  c.drawArc(const Rect.fromLTWH(5.4, 8.0, 13.2, 5.4), 0, math.pi, false, p);
}

void _clockPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 8.2, p);
  final hands = Path()
    ..moveTo(12, 7.2)
    ..lineTo(12, 12.4)
    ..lineTo(15.4, 14.4);
  c.drawPath(hands, p);
}

void _alertPaint(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 8.2, p);
  c.drawLine(const Offset(12, 7.4), const Offset(12, 13.2), p);
  c.drawCircle(const Offset(12, 16.4), 0.9, _fillPaint(p.color));
}

void _bookPaint(Canvas c, Paint p) {
  final b = Path()
    ..moveTo(12, 6.6)
    ..cubicTo(10.2, 5.1, 7.4, 4.8, 4.4, 5.1)
    ..lineTo(4.4, 18.0)
    ..cubicTo(7.4, 17.7, 10.2, 18.0, 12, 19.5)
    ..cubicTo(13.8, 18.0, 16.6, 17.7, 19.6, 18.0)
    ..lineTo(19.6, 5.1)
    ..cubicTo(16.6, 4.8, 13.8, 5.1, 12, 6.6)
    ..close();
  c.drawPath(b, p);
  c.drawLine(const Offset(12, 6.6), const Offset(12, 19.5), p);
}

void _quillPaint(Canvas c, Paint p) {
  final shaft = Path()
    ..moveTo(5.4, 18.6)
    ..cubicTo(7.4, 13.0, 11.4, 7.6, 19.2, 4.6)
    ..cubicTo(18.6, 12.8, 14.4, 17.0, 8.2, 17.4)
    ..cubicTo(7.2, 17.5, 6.2, 18.0, 5.4, 18.6)
    ..close();
  c.drawPath(shaft, p);
  c.drawLine(const Offset(4, 20.4), const Offset(8.2, 17.4), p);
  c.drawLine(const Offset(8.6, 13.8), const Offset(13.6, 13.0), p);
}

void _bulbPaint(Canvas c, Paint p) {
  final bowl = Path()
    ..moveTo(7.6, 10.2)
    ..cubicTo(7.6, 12.6, 9.0, 13.4, 9.4, 14.6)
    ..lineTo(14.6, 14.6)
    ..cubicTo(15.0, 13.4, 16.4, 12.6, 16.4, 10.2)
    ..cubicTo(16.4, 7.4, 14.4, 5.4, 12, 5.4)
    ..cubicTo(9.6, 5.4, 7.6, 7.4, 7.6, 10.2)
    ..close();
  c.drawPath(bowl, p);
  c.drawLine(const Offset(10, 16.4), const Offset(10, 17.6), p);
  c.drawLine(const Offset(14, 16.4), const Offset(14, 17.6), p);
  final base = RRect.fromRectAndRadius(
    const Rect.fromLTWH(9.4, 17.6, 5.2, 2.4),
    const Radius.circular(1.2),
  );
  c.drawRRect(base, p);
}

/// The icon catalogue.
class LpIcons {
  LpIcons._();

  // Navigation
  static const home = LpIconData(_homePaint);
  static const dictionary = LpIconData(_dictionaryPaint);
  static const library = LpIconData(_libraryPaint);
  static const translator = LpIconData(_translatorPaint);
  static const settings = LpIconData(_settingsPaint);

  // Actions
  static const search = LpIconData(_searchPaint);
  static const searchOff = LpIconData(_searchOffPaint);
  static const volumeUp = LpIconData(_volumeUpPaint);
  static const volume = LpIconData(_volumePaint);
  static const mic = LpIconData(_micPaint);
  static const swap = LpIconData(_swapPaint);
  static const star = LpIconData(_starPaint);
  static const starFilled = LpIconData(_starFilledPaint);
  static const bookmark = LpIconData(_bookmarkPaint);
  static const bookmarkFilled = LpIconData(_bookmarkFilledPaint);
  static const share = LpIconData(_sharePaint);
  static const trash = LpIconData(_trashPaint);
  static const close = LpIconData(_closePaint);
  static const check = LpIconData(_checkPaint);
  static const copy = LpIconData(_copyPaint);
  static const backspace = LpIconData(_backspacePaint);

  // Directional (RTL-aware)
  static const chevronLeft = LpIconData(_chevronLeftPaint);
  static const chevronRight = LpIconData(_chevronRightPaint);

  // Theme
  static const moon = LpIconData(_moonPaint);
  static const sun = LpIconData(_sunPaint);
  static const autoTheme = LpIconData(_autoThemePaint);

  // Content states
  static const sparkle = LpIconData(_sparklePaint);
  static const globe = LpIconData(_globePaint);
  static const clock = LpIconData(_clockPaint);
  static const alert = LpIconData(_alertPaint);
  static const book = LpIconData(_bookPaint);
  static const quill = LpIconData(_quillPaint);
  static const bulb = LpIconData(_bulbPaint);
}
