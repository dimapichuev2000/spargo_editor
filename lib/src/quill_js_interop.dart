import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Глобальный объект window
@JS()
external JSObject get window;

/// Проверить готовность Quill
@JS('window.quillReady')
external JSBoolean? get _quillReady;

/// Проверить, загружен ли Quill
bool isQuillLoaded() {
  try {
    // Проверяем флаг готовности
    final ready = _quillReady;
    if (ready != null && ready.toDart) {
      return true;
    }
    
    // Fallback: проверяем наличие функций
    return window.has('Quill') && window.has('createQuillEditor');
  } catch (e) {
    return false;
  }
}

/// Обертка для создания Quill редактора (определена в index.html)
@JS('createQuillEditor')
external QuillEditor _createQuillEditor(JSObject container, JSObject options);

/// Создать новый экземпляр Quill редактора
QuillEditor createQuillEditor(JSObject container, JSObject options) {
  if (!isQuillLoaded()) {
    throw Exception('Quill is not loaded');
  }
  
  return _createQuillEditor(container, options);
}

/// JS Interop для работы с Quill.js редактором
extension type QuillEditor._(JSObject _) implements JSObject {

  /// Получить содержимое редактора в формате Delta
  external JSObject getContents();

  /// Получить текст редактора
  external JSString getText();

  /// Установить содержимое редактора в формате Delta
  external void setContents(JSObject delta);

  /// Получить root элемент редактора
  @JS('root')
  external JSObject get root;

  /// Получить HTML содержимое редактора
  String getHTML() {
    return root.innerHTML.toDart;
  }

  /// Установить HTML содержимое редактора
  void setHTML(String html) {
    root.innerHTML = html.toJS;
  }

  /// Включить/выключить редактор
  external void enable(JSBoolean? enabled);

  /// Установить фокус на редактор
  external void focus();

  /// Получить длину текста
  external JSNumber getLength();

  /// Вставить текст
  external void insertText(JSNumber index, JSString text);

  /// Удалить текст
  external void deleteText(JSNumber index, JSNumber length);

  /// Форматировать текст
  external void formatText(JSNumber index, JSNumber length, JSString format, JSAny value);

  /// Получить выделение (selection)
  @JS('getSelection')
  external JSObject? getSelection();

  /// Подписаться на событие изменения текста
  external void on(JSString eventName, JSFunction callback);
}

/// Опции для создания Quill редактора
extension type QuillOptions._(JSObject _) implements JSObject {
  external factory QuillOptions({
    JSString? theme,
    JSString? placeholder,
    JSBoolean? readOnly,
    JSObject? modules,
  });
}

/// Модули для Quill
extension type QuillModules._(JSObject _) implements JSObject {
  external factory QuillModules({
    JSAny? toolbar,
  });
}

/// Глобальный объект document
@JS('document')
external JSObject get document;

/// Метод getElementById на document
extension DocumentExtension on JSObject {
  @JS('getElementById')
  external JSObject? getElementById(JSString id);

  @JS('createElement')
  external JSObject createElement(JSString tagName);
}

/// Методы для работы с HTML элементами
extension HTMLElementExtension on JSObject {
  @JS('appendChild')
  external void appendChild(JSObject child);

  @JS('removeChild')
  external void removeChild(JSObject child);

  @JS('innerHTML')
  external set innerHTML(JSString value);

  @JS('innerHTML')
  external JSString get innerHTML;

  @JS('style')
  external JSObject get style;

  @JS('id')
  external set id(JSString value);
}

/// Расширение для работы со стилями элемента
extension StyleExtension on JSObject {
  @JS('height')
  external set height(JSString value);

  @JS('minHeight')
  external set minHeight(JSString value);
}
