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

