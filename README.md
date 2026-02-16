# Quill Editor Widget

Flutter виджет для работы с Quill.js редактором на веб-платформе.

## Описание

`QuillEditorWidget` - это Flutter виджет, который предоставляет интеграцию с Quill.js редактором для веб-приложений. Виджет поддерживает форматирование текста, списки, ссылки, изображения и другие возможности Quill.js.

## Установка

### Локальная зависимость

Добавьте пакет в ваш `pubspec.yaml`:

```yaml
dependencies:
  quill_editor:
    path: packages/quill_editor
```
## Настройка веб-платформы

**⚠️ ВАЖНО:** Для корректной работы виджета необходимо настроить веб-платформу.

Начальные визуальные составляющие и настройки выглядят так, как в `web/index.html` основного проекта. 

### Шаг 1: Установка библиотек

Убедитесь, что файлы `quill.js` и `quill.snow.css` размещены в `web/libs/` вашего проекта.

### Шаг 2: Добавление в `web/index.html`

Скопируйте и вставьте следующие фрагменты в ваш `web/index.html`:

#### Добавление JavaScript в `web/index.html`

В секцию `<body>` (перед закрывающим тегом `</body>`):

```html
<!-- Quill.js -->
<script src="libs/quill.js"></script>

В секцию `<head>` (после других стилей):

```html
<!-- Quill.js CSS -->
<link href="libs/quill.snow.css" rel="stylesheet">
```
#### Рекомендуемая обертка над корнем приложения 

```dart
import 'package:spargo_editor/spargo_editor.dart';

MaterialApp(
  builder: (context, child) {
    return QuillKeyboardShortcuts(
      child: child ?? const SizedBox.shrink(),
    );
  },
  // ...
)
```

#### Опционально: Настройка UI стилей

Если вы хотите настроить внешний вид редактора (скругленные углы, отступы, стили кнопок), добавьте в секцию `<head>` после подключения CSS. Пример:

```html
<style>
  /* Стили для корректной работы Quill редактора с прокруткой */
  [id^="quill-editor-"] {
    display: flex;
    flex-direction: column;
  }
  
  [id^="quill-editor-"] .ql-toolbar {
    flex-shrink: 0;
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
    border: none !important;
    border-bottom: 1px solid #C4CCD8 !important;
  }
  
  /* Стили для кнопок toolbar */
  [id^="quill-editor-"] .ql-toolbar button {
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    width: 28px !important;
    height: 28px !important;
    padding: 0 !important;
    margin: 0 1px !important;
    border: 0 !important;
    border-radius: 4px !important;
    background: transparent !important;
    cursor: pointer !important;
    transition: background-color 0.15s ease !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar button:hover {
    background-color: #F3F4F6 !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar button.ql-active {
    background-color: #E5E7EB !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar button:focus {
    outline: none !important;
  }
  
  /* SVG иконки */
  [id^="quill-editor-"] .ql-toolbar button svg {
    width: 18px !important;
    height: 18px !important;
    flex-shrink: 0 !important;
  }
  
  /* Выпадающие списки (заголовки) */
  [id^="quill-editor-"] .ql-toolbar .ql-picker-label {
    border: 0 !important;
    border-radius: 4px !important;
    padding-left: 8px !important;
    padding-right: 20px !important;
    height: 28px !important;
    line-height: 28px !important;
    transition: background-color 0.15s ease !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-picker-label:hover {
    background-color: #F3F4F6 !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-picker.ql-expanded .ql-picker-label {
    background-color: #E5E7EB !important;
  }
  
  /* Кнопка выбора цвета */
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker {
    width: 28px !important;
    height: 28px !important;
    display: inline-flex !important;
    align-items: center !important;
    vertical-align: middle !important;
    position: relative !important;
    top: 2px !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-label {
    padding: 2px 4px !important;
    width: 28px !important;
    height: 28px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-label svg {
    margin: 0 auto !important;
  }
  
  /* Выпадающая панель с цветами */
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker.ql-expanded .ql-picker-options {
    display: block !important;
    position: absolute !important;
    z-index: 1000 !important;
    background-color: white !important;
    border: 1px solid #C4CCD8 !important;
    border-radius: 4px !important;
    padding: 8px !important;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15) !important;
    margin-top: 3px !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-options {
    display: none;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-item {
    border-radius: 2px !important;
    cursor: pointer !important;
    transition: border 0.1s ease !important;
  }
  
  [id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-item:hover {
    border: 2px solid #06c !important;
  }
  
  /* Стили для кнопок отступов */
  [id^="quill-editor-"] .ql-toolbar .ql-indent,
  [id^="quill-editor-"] .ql-toolbar .ql-outdent {
    display: inline-block;
    width: 28px;
    height: 28px;
  }
  
  /* Стили для групп элементов */
  [id^="quill-editor-"] .ql-toolbar .ql-formats {
    margin-right: 4px;
    display: inline-flex;
    align-items: center;
  }
  
  [id^="quill-editor-"] .ql-container {
    flex: 1;
    overflow-y: auto;
    border-bottom-left-radius: 8px;
    border-bottom-right-radius: 8px;
    border: none !important;
  }
  
  [id^="quill-editor-"] .ql-editor {
    min-height: 100%;
    padding: 12px 15px;
  }
</style>
```



## Использование

### Базовое использование

```dart
import 'package:quill_editor/quill_editor.dart';

QuillEditorWidget(
  initialContent: '<p>Начальный текст</p>',
  height: 400,
  placeholder: 'Введите текст...',
  onChanged: (html) {
    print('Изменено: $html');
  },
)
```

### Параметры

- `initialContent` (String?) - Начальное содержимое в формате HTML
- `onChanged` (ValueChanged<String>?) - Callback при изменении содержимого
- `placeholder` (String) - Placeholder текст (по умолчанию: 'Введите текст...')
- `height` (double) - Высота редактора (по умолчанию: 400)
- `readOnly` (bool) - Режим только для чтения (по умолчанию: false)

### Методы виджета

Для доступа к методам редактора используйте `GlobalKey`:

```dart
final editorKey = GlobalKey<_QuillEditorWidgetState>();

QuillEditorWidget(
  key: editorKey,
  // ...
)

// Получить HTML содержимое
String? html = editorKey.currentState?.getHTML();

// Получить текстовое содержимое
String? text = editorKey.currentState?.getText();

// Установить содержимое
editorKey.currentState?.setContent('<p>Новый текст</p>');
```

## Поддерживаемые платформы

- **Web** (основная платформа) - требует настройки `web/index.html`
- Другие платформы не поддерживаются (виджет использует веб-специфичные API)

## Пример

См. файл `example/main.dart` для полного примера использования.

