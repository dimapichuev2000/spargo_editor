import 'dart:html' as html;
import 'dart:js_interop';

bool _keyboardScriptInjected = false;
bool _quillInitInjected = false;
bool _quillStylesInjected = false;

void _injectKeyboardScript() {
  if (_keyboardScriptInjected) return;
  _keyboardScriptInjected = true;
  final script = html.ScriptElement()
    ..text = r'''
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
  html.document.body?.append(script);
}

void _injectQuillInitScript() {
  if (_quillInitInjected) return;
  _quillInitInjected = true;
  final script = html.ScriptElement()
    ..text = r'''
(function () {
  function init() {
    if (typeof Quill === 'undefined') return;
    window.createQuillEditor = function (container, options) {
      var editor = new Quill(container, options);
      var editorElement = editor.root;
      editorElement.setAttribute('spellcheck', 'true');
      editorElement.setAttribute('lang', 'ru');
      editorElement.spellcheck = true;
      return editor;
    };
    window.quillReady = true;
  }
  init();
  if (typeof window !== 'undefined') {
    window.addEventListener('load', init);
  }
})();
''';
  html.document.head?.append(script);
}

void _injectQuillEditorStyles() {
  if (_quillStylesInjected) return;
  _quillStylesInjected = true;
  final style = html.StyleElement()
    ..text = r'''
[id^="quill-editor-"]{display:flex;flex-direction:column}[id^="quill-editor-"] .ql-toolbar{flex-shrink:0;border-top-left-radius:8px;border-top-right-radius:8px;border:none!important;border-bottom:1px solid #C4CCD8!important}[id^="quill-editor-"] .ql-toolbar button{display:inline-flex!important;align-items:center!important;justify-content:center!important;width:28px!important;height:28px!important;padding:0!important;margin:0 1px!important;border:0!important;border-radius:4px!important;background:transparent!important;cursor:pointer!important;transition:background-color .15s ease!important}[id^="quill-editor-"] .ql-toolbar button:hover{background-color:#F3F4F6!important}[id^="quill-editor-"] .ql-toolbar button.ql-active{background-color:#E5E7EB!important}[id^="quill-editor-"] .ql-toolbar button:focus{outline:none!important}[id^="quill-editor-"] .ql-toolbar button svg{width:18px!important;height:18px!important;flex-shrink:0!important}[id^="quill-editor-"] .ql-toolbar .ql-picker-label{border:0!important;border-radius:4px!important;padding-left:8px!important;padding-right:20px!important;height:28px!important;line-height:28px!important;transition:background-color .15s ease!important}[id^="quill-editor-"] .ql-toolbar .ql-picker-label:hover{background-color:#F3F4F6!important}[id^="quill-editor-"] .ql-toolbar .ql-picker.ql-expanded .ql-picker-label{background-color:#E5E7EB!important}[id^="quill-editor-"] .ql-toolbar .ql-color-picker{width:28px!important;height:28px!important;display:inline-flex!important;align-items:center!important;vertical-align:middle!important;position:relative!important;top:2px!important}[id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-label{padding:2px 4px!important;width:28px!important;height:28px!important;display:flex!important;align-items:center!important;justify-content:center!important}[id^="quill-editor-"] .ql-toolbar .ql-color-picker.ql-expanded .ql-picker-options{display:block!important;position:absolute!important;z-index:1000!important;background-color:#fff!important;border:1px solid #C4CCD8!important;border-radius:4px!important;padding:8px!important;box-shadow:0 2px 8px rgba(0,0,0,.15)!important;margin-top:3px!important}[id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-options{display:none}[id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-item{border-radius:2px!important;cursor:pointer!important;transition:border .1s ease!important}[id^="quill-editor-"] .ql-toolbar .ql-color-picker .ql-picker-item:hover{border:2px solid #06c!important}[id^="quill-editor-"] .ql-toolbar .ql-indent,[id^="quill-editor-"] .ql-toolbar .ql-outdent{display:inline-block;width:28px;height:28px}[id^="quill-editor-"] .ql-toolbar .ql-formats{margin-right:4px;display:inline-flex;align-items:center}[id^="quill-editor-"] .ql-container{flex:1;overflow-y:auto;border-bottom-left-radius:8px;border-bottom-right-radius:8px;border:none!important}[id^="quill-editor-"] .ql-editor{min-height:100%;padding:12px 15px}
''';
  html.document.head?.append(style);
}

void ensureQuillWebAssetsInjected() {
  _injectQuillInitScript();
  _injectQuillEditorStyles();
}

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
