import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'quill_js_interop.dart';
import 'quill_keyboard_bridge.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

/// Виджет для отображения Quill.js редактора
class QuillEditorWidget extends StatefulWidget {
  const QuillEditorWidget({
    super.key,
    this.initialContent,
    this.onChanged,
    this.placeholder = 'Введите текст...',
    this.height = 400,
    this.readOnly = false,
  });

  /// Начальное содержимое в формате HTML
  final String? initialContent;

  /// Callback при изменении содержимого
  final ValueChanged<String>? onChanged;

  /// Placeholder текст
  final String placeholder;

  /// Высота редактора
  final double height;

  /// Режим только для чтения
  final bool readOnly;

  @override
  State<QuillEditorWidget> createState() => _QuillEditorWidgetState();
}

class _QuillEditorWidgetState extends State<QuillEditorWidget> {
  late final String _editorId;
  QuillEditor? _quillEditor;
  int _initAttempts = 0;

  @override
  void initState() {
    super.initState();
    _editorId = 'quill-editor-${const Uuid().v4()}';
    _registerViewFactory();
  }

  @override
  void didUpdateWidget(QuillEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly && _quillEditor != null) {
      _updateReadOnly();
    }
    // Обновляем содержимое редактора при изменении initialContent
    if (oldWidget.initialContent != widget.initialContent && _quillEditor != null) {
      _updateContent();
    }
  }

  void _updateContent() {
    if (_quillEditor == null || widget.initialContent == null) return;
    try {
      _quillEditor!.setHTML(widget.initialContent!);
    } catch (_) {}
  }

  /// Публичный метод для программного обновления содержимого редактора
  void setContent(String html) {
    if (_quillEditor == null) return;
    try {
      _quillEditor!.setHTML(html);
    } catch (_) {}
  }

  void _updateReadOnly() {
    if (_quillEditor == null) return;
    
    try {
      // Обновляем readOnly через enable() - enable(true) включает редактирование
      final enabled = !widget.readOnly;
      _quillEditor!.enable(enabled.toJS);
      
      // Обновляем CSS стили toolbar
      final containerElement = html.document.getElementById(_editorId);
      if (containerElement != null) {
        final toolbar = containerElement.querySelector('.ql-toolbar');
        if (toolbar != null) {
          if (widget.readOnly) {
            toolbar.style
              ..pointerEvents = 'none'
              ..opacity = '1'
              ..cursor = 'not-allowed';
          } else {
            toolbar.style
              ..pointerEvents = 'auto'
              ..opacity = '1'
              ..cursor = 'pointer';
          }
        }
      }
    } catch (_) {}
  }

  // Константы
  static const _pasteDelayMs = 50;
  static final _urlRegex = RegExp(
    r'(https?://[^\s<>"{}|\\^`\[\]]+|www\.[^\s<>"{}|\\^`\[\]]+|[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}[^\s<>"{}|\\^`\[\]]*)',
    caseSensitive: false,
  );

  /// Настройка обработчика вставки: преобразование URL в ссылки и очистка стилей
  void _setupPasteHandler() {
    if (_quillEditor == null) return;
    
    try {
      final editorElement = _getEditorElement();
      if (editorElement != null) {
        editorElement.onPaste.listen((e) {
          Future.delayed(const Duration(milliseconds: _pasteDelayMs), () {
            _processPastedContent();
          });
        });
      }
    } catch (_) {}
  }

  /// Обработка вставленного контента: конвертация URL в ссылки через Quill API.
  /// Не трогает innerHTML — курсор и всё форматирование (цвет, списки и т.д.) сохраняются.
  /// Уже оформленные ссылки пропускаются → можно вставлять сколько угодно ссылок.
  void _processPastedContent() {
    if (_quillEditor == null) return;
    try {
      spargoApplyUrlLinks(_quillEditor!);
    } catch (_) {}
    final editorElement = _getEditorElement();
    if (editorElement != null) {
      _ensureLinksAreActive(editorElement);
    }
  }

  /// Получение элемента редактора
  html.HtmlElement? _getEditorElement() {
    try {
      final container = html.document.getElementById(_editorId);
      return container?.querySelector('.ql-editor') as html.HtmlElement?;
    } catch (_) {
      return null;
    }
  }

  /// Преобразование URL в тексте в кликабельные ссылки
  void _convertUrlsToLinks(html.HtmlElement editorElement) {
    try {
      final htmlContent = editorElement.innerHtml;
      if (htmlContent == null || htmlContent.isEmpty) return;

      // Если уже есть ссылки, пропускаем преобразование
      if (htmlContent.contains('<a ')) return;

      final textContent = editorElement.text ?? '';
      if (textContent.isEmpty) return;

      final matches = _urlRegex.allMatches(textContent);
      if (matches.isEmpty) return;

      String newHtml = htmlContent;
      // Обрабатываем URL в обратном порядке, чтобы не сбить позиции
      for (final match in matches.toList()..sort((a, b) => b.start.compareTo(a.start))) {
        final url = match.group(0);
        if (url == null) continue;

        final normalizedUrl = _normalizeUrl(url);
        final escapedUrl = _escapeHtmlAttribute(url);
        final escapedNormalizedUrl = _escapeHtmlAttribute(normalizedUrl);

        newHtml = newHtml.replaceAllMapped(
          RegExp(RegExp.escape(url)),
          (_) => '<a href="$escapedNormalizedUrl">$escapedUrl</a>',
        );
      }

      if (newHtml != htmlContent) {
        editorElement.innerHtml = newHtml;
        editorElement.dispatchEvent(html.CustomEvent('input'));
      }
    } catch (_) {}
  }

  /// Нормализация URL (добавление https:// если нужно)
  String _normalizeUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return url.startsWith('www.') ? 'https://$url' : 'https://$url';
  }

  /// Очистка inline-стилей color и background-color (исключая ссылки и элементы с классами Quill)
  /// Не трогаем элементы внутри <a>, чтобы не сбивать форматирование ссылок.
  void _cleanInlineStyles(html.HtmlElement editorElement) {
    try {
      for (final el in editorElement.querySelectorAll('*')) {
        if (el is! html.HtmlElement || el.tagName.toLowerCase() == 'a') continue;
        // Не удаляем стили у содержимого внутри ссылки — сохраняем форматирование ссылки
        if (_isInsideLink(el)) continue;
        final classes = el.className.toString();
        final hasQuillColorClass = classes.contains('ql-color-') || classes.contains('ql-bg-');
        if (!hasQuillColorClass) {
          el.style.removeProperty('color');
          el.style.removeProperty('background-color');
        }
      }
    } catch (_) {}
  }

  /// Проверка, находится ли элемент внутри тега <a>
  bool _isInsideLink(html.HtmlElement el) {
    html.Element? parent = el.parent;
    while (parent != null) {
      if (parent.tagName.toLowerCase() == 'a') return true;
      parent = parent.parent;
    }
    return false;
  }

  /// Проверка и восстановление активности ссылок
  void _ensureLinksAreActive(html.HtmlElement editorElement) {
    try {
      for (final link in editorElement.querySelectorAll('a')) {
        if (link is html.AnchorElement) {
          final href = link.href;
          if (href == null || href.isEmpty || href == 'null' || href == 'undefined') {
            final text = link.text;
            if (text != null && text.isNotEmpty && _isUrlLike(text)) {
              link.href = _normalizeUrl(text);
            }
          }
          link.style
            ..pointerEvents = 'auto'
            ..cursor = 'pointer';
        }
      }
    } catch (_) {}
  }

  /// Проверка, похож ли текст на URL
  bool _isUrlLike(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.') ||
        text.contains('.');
  }

  /// Экранирование атрибутов HTML
  String _escapeHtmlAttribute(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  void _registerViewFactory() {
    ensureQuillWebAssetsInjected();
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_editorId, (int viewId) {
      final container = html.DivElement()
        ..id = _editorId
        ..style.height = '${widget.height}px'
        ..style.width = '100%'
        ..style.display = 'flex'
        ..style.flexDirection = 'column';

      final editorDiv = html.DivElement()
        ..id = '$_editorId-editor'
        ..style.display = 'flex'
        ..style.flexDirection = 'column'
        ..style.flex = '1'
        ..style.minHeight = '0';
      container.append(editorDiv);

      const maxFrames = 60; // ~1 сек при 60 FPS
      var framesWaited = 0;
      void tryInit() {
        if (!mounted || framesWaited >= maxFrames) return;
        if (html.document.getElementById(editorDiv.id) == null) {
          framesWaited++;
          html.window.animationFrame.then((_) => tryInit());
          return;
        }
        _initializeQuill(editorDiv.id);
      }
      html.window.animationFrame.then((_) => tryInit());

      return container;
    });
  }

  void _initializeQuill(String editorContainerId) {
    try {
      if (!isQuillLoaded()) {
        _initAttempts++;
        if (_initAttempts >= 30) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Не удалось загрузить редактор'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _initializeQuill(editorContainerId);
        });
        return;
      }

      final editorContainer = document.getElementById(editorContainerId.toJS);
      if (editorContainer == null) return;

      // Toolbar: Heading, форматирование, цвет текста, списки, отступы, ссылки, изображения
      final toolbarOptions = [
        [{'header': [1, 2, 3, false].jsify()}.jsify()].jsify(),
        ['bold', 'italic', 'underline', 'strike'].map((e) => e.toJS).toList().jsify(),
        [{'color': <JSAny?>[].jsify()}.jsify()].jsify(),
        [{'list': 'ordered'.toJS}.jsify(), {'list': 'bullet'.toJS}.jsify()].jsify(),
        [{'indent': '-1'.toJS}.jsify(), {'indent': '+1'.toJS}.jsify()].jsify(),
        ['link', 'image'].map((e) => e.toJS).toList().jsify(),
      ].jsify();

      final options = QuillOptions(
        theme: 'snow'.toJS,
        placeholder: widget.placeholder.toJS,
        readOnly: widget.readOnly.toJS,
        modules: QuillModules(toolbar: toolbarOptions),
      );

      _quillEditor = createQuillEditor(editorContainer, options);

      // Настройка обработки вставки для сохранения ссылок и очистки стилей
      _setupPasteHandler();

      // В режиме readOnly отключаем взаимодействие с toolbar через CSS
      _updateReadOnly();

      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        _quillEditor!.setHTML(widget.initialContent!);
      }

      if (widget.onChanged != null) {
        _quillEditor!.on('text-change'.toJS, (() {
          // Не очищаем inline-стили при обычных изменениях текста,
          // чтобы сохранить цвета, установленные через Quill цветовой пикер.
          // Очистка стилей происходит только при вставке (paste).
          final editorElement = _getEditorElement();
          if (editorElement != null) {
            _ensureLinksAreActive(editorElement);
          }
          widget.onChanged?.call(_quillEditor!.getHTML());
        }).toJS);
      }

    } catch (_) {}
  }

  /// Получить HTML содержимое редактора
  String? getHTML() {
    try {
      return _quillEditor?.getHTML();
    } catch (_) {
      return null;
    }
  }

  /// Получить текстовое содержимое редактора
  String? getText() {
    try {
      return _quillEditor?.getText().toDart;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: HtmlElementView(
          viewType: _editorId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quillEditor = null;
    super.dispose();
  }
}
