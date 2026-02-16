import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'quill_keyboard_bridge.dart';

/// Оборачивает дерево виджетов и обрабатывает Tab и Space для активного Quill:
/// если фокус в Quill — Tab вставляет 4 пробела, Space вставляет пробел;
/// иначе Tab переключает фокус, Space не перехватывается.
class QuillKeyboardShortcuts extends StatelessWidget {
  const QuillKeyboardShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.tab): _QuillTabIntent(backward: false),
        SingleActivator(LogicalKeyboardKey.tab, shift: true):
            _QuillTabIntent(backward: true),
        SingleActivator(LogicalKeyboardKey.space): _QuillSpaceIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _QuillTabIntent: CallbackAction<_QuillTabIntent>(
            onInvoke: (intent) {
              if (spargoTryInsertTabSpacesAtActiveQuill()) {
                return null;
              }
              final scope = FocusScope.of(context);
              if (intent.backward) {
                scope.previousFocus();
              } else {
                scope.nextFocus();
              }
              return null;
            },
          ),
          _QuillSpaceIntent: CallbackAction<_QuillSpaceIntent>(
            onInvoke: (_) {
              if (spargoTryInsertSpaceAtActiveQuill()) {
                return null;
              }
              return KeyEventResult.ignored;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _QuillTabIntent extends Intent {
  const _QuillTabIntent({required this.backward});
  final bool backward;
}

class _QuillSpaceIntent extends Intent {
  const _QuillSpaceIntent();
}
