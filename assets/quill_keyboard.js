(function () {
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
