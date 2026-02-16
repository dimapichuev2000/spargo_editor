import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'quill_keyboard_bridge.dart';

/// Оборачивает дерево виджетов и обрабатывает Tab и Space для активного Quill:
/// - Tab: если фокус в Quill — вставляет 4 пробела; иначе переключает фокус
/// - Space: если фокус в Quill — вставляет пробел; иначе передаёт событие дальше
/// Используется Focus.onKeyEvent для корректной передачи событий в обычные поля ввода.
class QuillKeyboardShortcuts extends StatelessWidget {
  const QuillKeyboardShortcuts({super.key, required this.child});

  final Widget child;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    // Обрабатываем только keyDown события
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Обработка Tab: если фокус в Quill, вставляем 4 пробела через JS
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (spargoTryInsertTabSpacesAtActiveQuill()) {
        return KeyEventResult.handled;
      }
      // Если не в Quill, передаём событие дальше для стандартной навигации по фокусу
      return KeyEventResult.ignored;
    }

    // Обработка Space: если фокус в Quill, вставляем пробел через JS
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (spargoTryInsertSpaceAtActiveQuill()) {
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKey,
      child: child,
    );
  }
}
