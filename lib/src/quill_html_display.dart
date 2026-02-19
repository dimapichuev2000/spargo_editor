import 'package:flutter/material.dart';

/// Утилиты для отображения Quill HTML во Flutter (например через flutter_widget_from_html).
///
/// Препроцессинг подставляет явные маркеры списков вместо CSS counter(),
/// т.к. Flutter-рендерер их не поддерживает.
class QuillHtmlDisplay {
  QuillHtmlDisplay._();

  /// Подготовленный HTML с явными маркерами списков (логика как в quill.snow.css).
  static String preprocessQuillHtml(String html) {
    final counters = List<int>.filled(10, 0);

    return html.replaceAllMapped(
      RegExp(
        r'<(p|h[1-6]|blockquote|pre)[\s>]|<li([^>]*)>(.*?)</li>',
        dotAll: true,
      ),
      (match) {
        if (match.group(1) != null) {
          counters.fillRange(0, 10, 0);
          return match.group(0)!;
        }

        final attrs = match.group(2) ?? '';
        final innerHtml = match.group(3) ?? '';

        final indentMatch = RegExp(r'ql-indent-(\d)').firstMatch(attrs);
        final indent =
            indentMatch != null ? int.parse(indentMatch.group(1)!) : 0;

        final dataListMatch = RegExp(r'data-list="([^"]+)"').firstMatch(attrs);
        final dataList = dataListMatch?.group(1) ?? '';

        for (var i = indent + 1; i < 10; i++) {
          counters[i] = 0;
        }

        final String markerText;
        if (dataList == 'ordered') {
          counters[indent]++;
          markerText = _quillOrderedMarker(counters[indent], indent);
        } else if (dataList == 'bullet') {
          markerText = '\u2022';
        } else if (dataList == 'checked') {
          markerText = '\u2611';
        } else if (dataList == 'unchecked') {
          markerText = '\u2610';
        } else {
          markerText = '';
        }

        final cleanInner = innerHtml.replaceAll(
          RegExp(
            r'<span[^>]*class="[^"]*ql-ui[^"]*"[^>]*>.*?</span>',
            dotAll: true,
          ),
          '',
        );

        const markerStyle =
            'display:inline-block;min-width:1.2em;margin-right:0.3em;'
            'text-align:right;white-space:nowrap';
        return '<li$attrs>'
            '<span style="$markerStyle">$markerText</span>'
            '$cleanInner'
            '</li>';
      },
    );
  }

  /// Стили для HtmlWidget (ol, li, p, a, ql-indent, ql-align).
  static Map<String, String>? buildStyles(BuildContext context, dynamic element) {
    final styles = <String, String>{};
    final tag = element.localName as String?;
    if (tag == null) return null;

    final classes = element.classes as Iterable<String>? ?? const [];

    if (tag == 'ol') {
      styles['margin'] = '0';
      styles['padding'] = '0';
    }

    if (tag == 'li') {
      styles['list-style-type'] = 'none';
      styles['padding-left'] = '0';
      styles['margin-bottom'] = '0.25em';
    }

    if (tag == 'p') {
      styles['margin'] = '0';
      styles['padding'] = '0';
    }

    if (tag == 'a') {
      styles['color'] =
          Theme.of(context).colorScheme.primary.toHexString();
      styles['text-decoration'] = 'underline';
    }

    final isRtl = classes.contains('ql-direction-rtl') &&
        classes.contains('ql-align-right');
    for (var i = 1; i <= 9; i++) {
      if (classes.contains('ql-indent-$i')) {
        final em = i * 3.0;
        if (isRtl) {
          styles['padding-right'] = '${em}em';
        } else {
          styles['padding-left'] = '${em}em';
        }
        break;
      }
    }

    if (classes.contains('ql-align-center')) {
      styles['text-align'] = 'center';
    } else if (classes.contains('ql-align-right')) {
      styles['text-align'] = 'right';
    } else if (classes.contains('ql-align-justify')) {
      styles['text-align'] = 'justify';
    }

    return styles.isNotEmpty ? styles : null;
  }

  static String _quillOrderedMarker(int count, int indent) {
    switch (indent % 3) {
      case 0:
        return '$count.';
      case 1:
        return '${_toLowerAlpha(count)}.';
      default:
        return '${_toLowerRoman(count)}.';
    }
  }

  static String _toLowerAlpha(int n) {
    var result = '';
    var num = n;
    while (num > 0) {
      num--;
      result = String.fromCharCode('a'.codeUnitAt(0) + num % 26) + result;
      num ~/= 26;
    }
    return result;
  }

  static String _toLowerRoman(int n) {
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const numerals = [
      'm', 'cm', 'd', 'cd', 'c', 'xc', 'l', 'xl', 'x', 'ix', 'v', 'iv', 'i'
    ];
    var result = '';
    var remaining = n;
    for (var i = 0; i < values.length; i++) {
      while (remaining >= values[i]) {
        result += numerals[i];
        remaining -= values[i];
      }
    }
    return result;
  }
}

extension _ColorToHex on Color {
  String toHexString() =>
      '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}
