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
<script>
  window.addEventListener('load', function() {
    if (typeof Quill !== 'undefined') {
      window.createQuillEditor = function(container, options) {
        const editor = new Quill(container, options);
        
        // Включаем проверку орфографии на русском языке
        const editorElement = editor.root;
        editorElement.setAttribute('spellcheck', 'true');
        editorElement.setAttribute('lang', 'ru');
        editorElement.spellcheck = true;
        
        return editor;
      };
      window.quillReady = true;
    }
  });
</script>
```

#### В секцию `<head>` (после других стилей):

```html
<!-- Quill.js CSS -->
<link href="libs/quill.snow.css" rel="stylesheet">
```

#### Опционально: Настройка UI стилей

Если вы хотите настроить внешний вид редактора (скругленные углы, отступы, стили кнопок), добавьте в секцию `<head>` после подключения CSS:

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
  
  /* Стили для всех кнопок toolbar */
  [id^="quill-editor-"] .ql-toolbar button {
    display: inline-block;
    width: 28px;
    height: 28px;
    padding: 0;
    margin: 0 1px;
    border: none;
    background: transparent;
    cursor: pointer;
  }
  
  [id^="quill-editor-"] .ql-toolbar button:hover {
    background-color: #F3F4F6;
    border-radius: 4px;
  }
  
  [id^="quill-editor-"] .ql-toolbar button.ql-active {
    background-color: #E5E7EB;
    border-radius: 4px;
  }
  
  /* Убеждаемся, что SVG иконки видны */
  [id^="quill-editor-"] .ql-toolbar button svg {
    display: block;
    width: 18px;
    height: 18px;
    margin: 0 auto;
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

