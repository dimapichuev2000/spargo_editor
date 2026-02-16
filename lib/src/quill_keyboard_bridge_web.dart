import 'dart:html' as html;
import 'dart:js_interop';

import 'package:flutter/services.dart' show rootBundle;

bool _keyboardScriptInjected = false;
Future<void>? _ensureInjectedFuture;
String? _keyboardScriptContent;

Future<void> ensureQuillWebAssetsInjected() async {
  if (_ensureInjectedFuture != null) return _ensureInjectedFuture!;
  _ensureInjectedFuture = _loadAndInject();
  await _ensureInjectedFuture;
}

Future<void> _loadAndInject() async {
  final initJs = await rootBundle.loadString('packages/spargo_editor/assets/quill_init.js');
  final css = await rootBundle.loadString('packages/spargo_editor/assets/quill_editor.css');
  final keyboardJs = await rootBundle.loadString('packages/spargo_editor/assets/quill_keyboard.js');
  _keyboardScriptContent = keyboardJs;

  final initScript = html.ScriptElement()..text = initJs;
  html.document.head?.append(initScript);

  final style = html.StyleElement()..text = css;
  html.document.head?.append(style);

  if (!_keyboardScriptInjected) {
    final keyboardScript = html.ScriptElement()..text = keyboardJs;
    html.document.body?.append(keyboardScript);
    _keyboardScriptInjected = true;
  }
}

void _injectKeyboardScript() {
  if (_keyboardScriptInjected) return;
  _keyboardScriptInjected = true;
  final content = _keyboardScriptContent ?? _keyboardScriptFallback;
  final script = html.ScriptElement()..text = content;
  html.document.body?.append(script);
}

const _keyboardScriptFallback = r'''
(function() {
  if (window.spargoInsertTabSpacesAtActiveQuill) return;
  window.spargoInsertTabSpacesAtActiveQuill = function () {
    var el = document.activeElement;
    if (!el || !el.closest) return false;
    if (!el.closest('.ql-editor')) return false;
    document.execCommand('insertText', false, '    ');
    return true;
  };
  window.spargoInsertSpaceAtActiveQuill = function () {
    var el = document.activeElement;
    if (!el || !el.closest) return false;
    if (!el.closest('.ql-editor')) return false;
    document.execCommand('insertText', false, ' ');
    return true;
  };
})();
''';

@JS('spargoInsertTabSpacesAtActiveQuill')
external JSBoolean? _spargoInsertTabSpacesAtActiveQuill();

@JS('spargoInsertSpaceAtActiveQuill')
external JSBoolean? _spargoInsertSpaceAtActiveQuill();

bool spargoTryInsertTabSpacesAtActiveQuill() {
  _injectKeyboardScript();
  final res = _spargoInsertTabSpacesAtActiveQuill();
  return res != null && res.toDart;
}

bool spargoTryInsertSpaceAtActiveQuill() {
  _injectKeyboardScript();
  final res = _spargoInsertSpaceAtActiveQuill();
  return res != null && res.toDart;
}
