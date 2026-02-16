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

      // В режиме readOnly отключаем взаимодействие с toolbar через CSS
      _updateReadOnly();

      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        _quillEditor!.setHTML(widget.initialContent!);
      }

      if (widget.onChanged != null) {
        _quillEditor!.on('text-change'.toJS, (() {
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

  /// Установить содержимое редактора
  void setContent(String html) {
    try {
      _quillEditor?.setHTML(html);
    } catch (_) {}
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
